# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.8.0] - 2023-01-31
- Add support for secret rotation ([49](https://github.com/waiting-for-dev/warden-jwt_auth/pull/49))
- Support dry-* v1 ([52](https://github.com/waiting-for-dev/warden-jwt_auth/pull/52))

## [0.7.0] - 2022-09-12
- Support asymmetric algorithms ([40](https://github.com/waiting-for-dev/warden-jwt_auth/issues/40))

## [0.6.0] - 2021-09-21
- Support ruby 3.0 and deprecate 2.5
- Fixed dry-configurable compatibility. ([28](https://github.com/waiting-for-dev/warden-jwt_auth/issues/28))

## [0.5.0] 
### Fixed
- Fixed dry-configurable compatibility. ([28](https://github.com/waiting-for-dev/warden-jwt_auth/issues/28))

## [0.4.2] - 2020-03-19
### Fixed
- Lock dry-configurable dependency to fix upstream regression. ([21](https://github.com/waiting-for-dev/warden-jwt_auth/issues/21))
- Fix ruby 2.7 warnings (@trevorrjohn [23](https://github.com/waiting-for-dev/warden-jwt_auth/pull/23) )

## [0.4.1] - 2020-02-23
### Fixed
- Upgrade dry-configurable dependency to fix upstream bug preventing
  warden-jwt_auth to be loaded ([21](https://github.com/waiting-for-dev/warden-jwt_auth/issues/21)).

## [0.4.0] - 2019-08-01
### Added
- Allow configuration of the signing algorithm ([19](https://github.com/waiting-for-dev/warden-jwt_auth/pull/19)].

## [0.3.6] - 2019-03-29
### Fixed
- Update depencies.

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
