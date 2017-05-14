---
title: About download.method
author: ~
date: '2016-12-26'
slug: 'dowload.method'
categories: [R]
tags: [R]
draft: true
---

# `download.file` methods in R

Working on a PR for `remotes` package ([this PR](https://github.com/r-pkgs/remotes/pull/46)), I looked into how `download.file` methods evolved with R version, trying to understand how it works depending on the system or the url type.

Here is my understanding.

## History of `download.file`
*from [R news](https://cran.r-project.org/doc/manuals/r-release/NEWS.html)*

### R 3.3.0

#### What is important
- All builds have support for https
- On windows, "auto" uses "libcurl" only for ftps
- On windows, `setInternet2` is depreciated (no effect) and will be removed
- On windows, "wininet" still is the default (since 3.2.2)

#### Extract from R news
- All builds have support for https: URLs in the default methods for `download.file()`, `url()` and code making use of them.  Unfortunately that cannot guarantee that any particular https: URL can be accessed. For example, server and client have to successfully negotiate a cryptographic protocol (TLS/SSL, ...) and the server's identity has to be verifiable via the available certificates. Different access methods may allow different protocols or use private certificate bundles: we encountered a https: CRAN mirror which could be accessed by one browser but not by another nor by download.file() on the same Linux machine.
- (Windows only) download.file() with default method = "auto" and a ftps:// URL chooses "libcurl" if that is available. 
- (Windows only) Function setInternet2() has no effect and will be removed in due course. The choice between methods "internal" and "wininet" is now made by the method arguments of url() and download.file() and their defaults can be set via options. The out-of-the-box default remains "wininet" (as it has been since R 3.2.2)

### R 3.2.5 
#### What is important
- On windows, "wininet" is now the default. It changes how proxy need to be set.
- On windows, "internal" uses "wininet" by defaut (setInternet2(TRUE)) - download.file can read https then.
- On non windows, "libcurl" is use by default if available and if url is https or ftps

#### Extract form R News
- It is now easier to use secure downloads from https:// URLs on builds which support them: no longer do non-default options need to be selected to do so. In particular, packages can be installed from repositories which offer https:// URLs, and those listed by setRepositories() now do so (for some of their mirrors).  Support for https:// URLs is available on Windows, and on other platforms if support for libcurl was compiled in and if that supports the https protocol (system installations can be expected to do). So https:// support can be expected except on rather old OSes (an example being OS X ‘Snow Leopard’, where a non-system version of libcurl can be used).
- (Windows only) The default method for accessing URLs via download.file() and url() has been changed to be "wininet" using Windows API calls. This changes the way proxies need to be set and security settings made: there have been some reports of ftp: sites being inaccessible under the new default method (but the previous methods remain available).
- (Non-Windows only) download.file() with default method = "auto" now chooses "libcurl" if that is available and a https:// or ftps:// URL is used
-  (Windows only) setInternet2(TRUE) is now the default. The command-line option --internet2 and environment variable R_WIN_INTERNET2 are now ignored.  Thus by default the "internal" method for download.file() and url() uses the "wininet" method: to revert to the previous default use setInternet2(FALSE).  This means that https:// URLs can be read by default by download.file() (they have been readable by file() and url() since R 3.2.0).  There are implications for how proxies need to be set (see ?download.file)

### R 3.2.0 

#### What is important
- Apparition of "libcurl" method 
- Apparition of "wininet" method
- download.file(method = "lynx") is defunct. 

#### Extract from R News

-  Optional use of libcurl (version 7.28.0 from Oct 2012 or later) for Internet access:
   - capabilities("libcurl") reports if this is available.
   - libcurlVersion() reports the version in use, and other details of the "libcurl" build including which URL schemes it supports.
   - curlGetHeaders() retrieves the headers for http://, https://, ftp:// and ftps:// URLs: analysis of these headers can provide insights into the ‘existence’ of a URL (it might for example be permanently redirected) and is so used in R CMD check --as-cran.
    - download.file() has a new optional method "libcurl" which will handle more URL schemes, follow redirections, and allows simultaneous downloads of multiple URLs.
    - url() has a new method "libcurl" which handles more URL schemes and follows redirections. The default method is controlled by a new option url.method, which applies also to the opening of URLs via file() (which happens implicitly in functions such as read.table.)
    - When file() or url() is invoked with a https:// or ftps:// URL which the current method cannot handle, it switches to a suitable method if one is available.
- (Windows.) The DLLs ‘internet.dll’ and ‘internet2.dll’ have been merged. In this version it is safe to switch (repeatedly) between the internal and Windows internet functions within an R session.  The Windows internet functions are still selected by flag --internet2 or setInternet2(). This can be overridden for an url() connection via its new method argument.
    - download.file() has new method "wininet", selected as the default by --internet2 or setInternet2().
    
### R 3.1.0

- download.file(method = "lynx") is deprecated. 

### Previous

I did not looked into previous version for now.

## What is going on in the R 3.3.2 ? 

### Default methods
- On non windows
   - "libcurl" is used by default for https and for ftps
   - "internal" is used by default for others url types
   - "wget" and "curl" can be selected but respective program must be installed
- On windows
   - "wininet" is used by default for all url types apart from ftps
   - "libcurl" is used by default for ftps url
      - However libcurl is optional on windows. Must be checked with  capabilities("libcurl")
   - "wget" and "curl" can be selected but respective program must be installed

### https support
- On windows
   - "libcurl"
   - "wininet"
- On non windows
   - "libcurl"
   - "wget"
   - "curl" 
   
- "internal" does not support https urls

### http & https redirection
- Only available with "libcurl" or "wget" by default
- Possible for "curl" by adding a argument using `extra = -L`
- "wininet" (windows only) supports some but not all

### percent decode url
- not possible
   - "internal"
   - "wininet"
   - "wget"
- possible
   - "libcurl"
   - "curl"

### percent encode 
Most methods do not percent-encode special characters such as spaces in URLs
It seems the "wininet" method does. 

### Proxy configuration

- for "wininet"
   - No configuration required as the ‘Internet Options’ of the system are used.
   - They are defined in Control Panel and used by Internet Explorer

- for "internal" only
   - Proxies can be specified via environment variables
      - `no_proxy = *` stops any proxies being tried
      - `http_proxy` or `ftp_proxy` 
      - with form http://proxy.dom.com/ or http://proxy.dom.com:8080/
   - authentification pass through `http_proxy_user` or `ftp_proxy_user` with the form `user:pwd`
   - could be set with the form `http_proxy =  http://user:pwd@proxy.dom.com:8080/`

- for "wget" compatibility
   - `no_proxy`, `http_proxy`, `ftp_proxy` can be used
   - authentification pass through `http_proxy` with the form http://user:pwd@proxy.dom.com:8080/
   - not compatible with `http_proxy_user` and `ftp_proxy_user`

- for "libcurl"
   - `http_proxy` & `ftp_proxy` can be used but the form is `[user:password@]machine[:port]`
   - not compatible with `http_proxy_user` and `ftp_proxy_user`

### about "wget" and "curl" ? 

- Methods "wget" and "curl" are mainly for historical compatibility but provide may provide capabilities not supported by the "libcurl" or "wininet" methods. 
- Method "wget" 
   - can be used with proxy firewalls which require user/password authentication if proper values are stored in the configuration file for wget
   - commonly installed on UNIX-alikes (not macOS). Windows binaries are available and can be installed
- Method "curl"
   - installed on MacOs an UNIX-alikes
   - Windows binaries are available too

### Secure URL and Libcurl

On windows "libcurl" is not always functionnal because the OS does not provide a suitable CA certificate bundle. 

> This is an issue for method = "libcurl" on Windows, where the OS does not provide a suitable CA certificate bundle, so by default on Windows certificates are not verified. To turn verification on, set environment variable CURL_CA_BUNDLE to the path to a certificate bundle file, usually named ‘ca-bundle.crt’ or ‘curl-ca-bundle.crt’. (This is normally done for a binary installation of R, which installs ‘R_HOME/etc/curl-ca-bundle.crt’ and sets CURL_CA_BUNDLE to point to it if that environment variable is not already set.) For an updated certificate bundle, see http://curl.haxx.se/docs/sslcerts.html. Currently one can download a copy from https://raw.githubusercontent.com/bagder/ca-bundle/master/ca-bundle.crt and set CURL_CA_BUNDLE to the full path to the downloaded file.

## What should we do in package like `remotes` ?

It depends on what R version we want to support.

Since R 3.2.0, supports of https is possible with "wininet" on windows and "libcurl" for non windows. However it was not by default and should be set manually.
   - "wininet" set by default for download by `setInternet2` on windows
   - "libcurl" had to be chosen as download method on other platform
By default, since R 3.2.5, default method in `download.file` can handle https url on platforms which supports them. 
   - On windows it is handled by "wininet"
   - On other platform by "libcurl" which must be available
By default, since R 3.3.0, all builds support https and by default. 
   - On windows it is handled by "wininet"
   - On other platform by "libcurl" which must be available
   - `setInternet2` is not used anymore 

1. For R > = 3.3.0 : default method for download.file handle https without anything else to be done
2. For 3.2.0 <= R < 3.3.0, method should be set to "wininet" on windows and "libcurl" if url is https
3. For R < 3.2.0, https was not supported. 

So, we may not need `remotes::download_method` anymore or we may adapt it for older version.

### Proxy configuration

The only thing that changes is proxy configuration. 
   - On windows, "wininet" is the default and use Internet Option setting. Nothing to be done
   - On non-windows, proxy must be set with `http_proxy = [user:pwd@]machine[:port]` in order to work with "libcurl". This form seems to be also compatible with other methods.
   
We could point to `download.help` file with a focus on "libcurl" configuration. 
