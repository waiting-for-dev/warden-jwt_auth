# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.3.5] - 2018-01-30
### Fixed
- Do not disallow fetching JWT scopes from session

## [0.3.4] - 2018-01-09
### Fixed
- Do not log out from session for standard AJAX requests

## [0.3.3] - 2017-12-31
### Fixed
- Check it is not a html request when disallowing fetching from session

## [0.3.2] - 2017-12-23
### Fixed
- Do not couple `aud_header` env value to the setting

## [0.3.1] - 2017-12-11
### Added
- Ensure JWT scopes are not fetched from session. Workaround for
  https://github.com/hassox/warden/pull/118

## [0.3.0] - 2017-12-06
### Added
- Add and call hook method `on_jwt_dispatch` on user instance
- Encode and validate an `aud` claim from the request headers

## [0.2.1] - 2017-12-04
### Added
- Allow configuring classes as strings

### Fixed
- Take `PATH_INFO` as an empty string when it is not present

## [0.2.0] - 2017-11-23
### Added
- `fail!` with message

### Fixed
- Unauthorize when fetched user is nil

## [0.1.4] - 2017-11-21
### Fixed
- Update `jwt` dependency

## [0.1.3] - 2017-04-15
### Fixed
- Coerce `sub` to string to conform with JWT specification

## [0.1.2] - 2017-04-13
### Fixed
- Ignore expired tokens on revocation instead of fail

## [0.1.1] - 2017-02-28
### Fixed
- Explicit require of `securerandom` standard library
