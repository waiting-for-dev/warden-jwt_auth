# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

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
