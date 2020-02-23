# Warden::JWTAuth

[![Gem Version](https://badge.fury.io/rb/warden-jwt_auth.svg)](https://badge.fury.io/rb/warden-jwt_auth)
[![Build Status](https://travis-ci.org/waiting-for-dev/warden-jwt_auth.svg?branch=master)](https://travis-ci.org/waiting-for-dev/warden-jwt_auth)
[![Code Climate](https://codeclimate.com/github/waiting-for-dev/warden-jwt_auth/badges/gpa.svg)](https://codeclimate.com/github/waiting-for-dev/warden-jwt_auth)
[![Test Coverage](https://codeclimate.com/github/waiting-for-dev/warden-jwt_auth/badges/coverage.svg)](https://codeclimate.com/github/waiting-for-dev/warden-jwt_auth/coverage)

`warden-jwt_auth` is a [warden](https://github.com/hassox/warden) extension which uses [JWT](https://jwt.io/) tokens for user authentication. It follows [secure by default](https://en.wikipedia.org/wiki/Secure_by_default) principle.

This gem is just a replacement for cookies when these can't be used. As
cookies, a token expired with `warden-jwt_auth` will mandatorily have an
expiration time. If you need that your users never sign out, you will be better
off with a solution using refresh tokens, like some implementation of OAuth2.

You can read about which security concerns this library takes into account and about JWT generic secure usage in the following series of posts:

- [Stand Up for JWT Revocation](http://waiting-for-dev.github.io/blog/2017/01/23/stand_up_for_jwt_revocation/)
- [JWT Revocation Strategies](http://waiting-for-dev.github.io/blog/2017/01/24/jwt_revocation_strategies/)
- [JWT Secure Usage](http://waiting-for-dev.github.io/blog/2017/01/25/jwt_secure_usage/)
- [A secure JWT authentication implementation for Rack and Rails](http://waiting-for-dev.github.io/blog/2017/01/26/a_secure_jwt_authentication_implementation_for_rack_and_rails/)

If what you need is a JWT authentication library for [devise](https://github.com/plataformatec/devise), better look at [devise-jwt](https://github.com/waiting-for-dev/devise-jwt), which is just a thin layer on top of this gem.

## Installation

```ruby
gem 'warden-jwt_auth'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install warden-jwt_auth

## Usage

You can look at this gem's wiki to see some [example applications](https://github.com/waiting-for-dev/warden-jwt_auth/wiki). Please, add yours if you think it can help somebody.

At its core, this library consists of:

- A Warden strategy that authenticates a user if a valid JWT token is present in the request headers.
- A rack middleware which adds a JWT token to the response headers in configured requests.
- A rack middleware which revokes JWT tokens in configured requests.

As you see, JWT revocation is supported. I wrote [why I think JWT tokens revocation is useful and needed](http://waiting-for-dev.github.io/blog/2017/01/23/stand_up_for_jwt_revocation/).

### Secret key configuration

First of all, you have to configure the secret key that will be used to sign generated tokens.

```ruby
Warden::JWTAuth.configure do |config|
  config.secret = ENV['WARDEN_JWT_SECRET_KEY']
end
```

**Important:** You are encouraged to use a dedicated secret key, different than others in use in your application. If several components share the same secret key, chances that a vulnerability in one of them has a wider impact increase. Also, never share your secrets pushing it to a remote repository, you are better off using an environment variable like in the example.

Currently, HS256 algorithm is the default.
Configure the matching secret and algorithm name to use a different one (e.g. RS256) (see [ruby-jwt](https://github.com/jwt/ruby-jwt#algorithms-and-usage) to see which are supported)
```ruby
Warden::JWTAuth.configure do |config|
  config.secret = OpenSSL::PKey::RSA.new(ENV['WARDEN_JWT_SECRET_KEY'])
  config.algorithm = ENV['WARDEN_JWT_ALGORITHM']
end
```

### Warden scopes configuration

You have to map the warden scopes that will be authenticatable through JWT, with the user repositories from where these scope user records can be fetched. If a string is supplied, the user repository will first be looked up as a constant.

For instance:

```ruby
config.mappings = { user: UserRepository }
```

For this example, `UserRepository` must implement a method `find_for_jwt_authentication` that takes as argument the `sub` claim in the JWT payload. This method should return a user record from `:user` scope:

```ruby
module UserRepository
  # @returns User
  def self.find_for_jwt_authentication(sub)
    Repo.find_user_by_id(sub)
  end
end
```

User records must implement a `jwt_subject` method returning what should be encoded in the `sub` claim on dispatch time. Be aware that what is returned must be coercible to string in order to conform with [RFC7519 standard for `sub` claim](https://tools.ietf.org/html/rfc7519#section-4.1.2).

```ruby
User = Struct.new(:id, :name)
  def jwt_subject
    id
  end
end
```

User records may also implement a `jwt_payload` method, which gives it a chance to add something to the JWT payload:

```ruby
def jwt_payload
  { 'foo' => 'bar' }
end
```

Just when a token is going to be dispatched to a client, a hook method `on_jwt_dispatch` is invoked, only when it exist, on the user record. This method takes the `token` and the `payload` as arguments.

```ruby
def on_jwt_dispatch(token, payload)
  # Do something
end
```

### Middlewares addition

You need to add `Warden::JWTAuth::Middleware` to your rack middlewares stack. Actually, it is just a wrapper which adds two middlewares that do the actual job: dispatching tokens and revoking tokens.

### Token dispatch configuration

You need to tell which requests will dispatch tokens for the user that has been previously authenticated (usually through some other warden strategy, such as one requiring username and email parameters).

To configure it, you must provide a bidimensional array, each item being an array of two elements: the request method and a regular expression that must match the request path.

For example:

```ruby
config.dispatch_requests = [
                             ['POST', %r{^/sign_in$}]
                           ]
```

**Important**: You are encouraged to delimit your regular expression with `^` and `$` to avoid unintentional matches.

Tokens will be returned in the `Authorization` response header, with format `Bearer #{token}`.

### Requests authentication

Once you have a valid token, you can authenticate following requests providing the token in the `Authorization` request header, with format `Bearer #{token}`.

### Revocation configuration

You need to tell which requests will revoke incoming JWT tokens.

To configure it, you must provide a bidimensional array, each item being an array of two elements: the request method and a regular expression that must match the request path.

For example:

```ruby
config.revocation_requests = [
                               ['DELETE', %r{^/sign_out$}]
                             ]
```

**Important**: You are encouraged to delimit your regular expression with `^` and `$` to avoid unintentional matches.

Besides, you need to configure which revocation strategy will be used for each scope. If a string is supplied, the revocation strategy will first be looked up as a constant.

```ruby
config.revocation_strategies = { user: RevocationStrategy }
```

The implementation of the revocation strategy is also on your side. They just need to implement two methods: `jwt_revoked?` and `revoke_jwt`, both of them accepting as parameters the JWT payload and the user record, in this order.

You can read about which [JWT recovation strategies](http://waiting-for-dev.github.io/blog/2017/01/24/jwt_revocation_strategies/) can be implement with their pros and cons.

```ruby
module RevocationStrategy
  def self.jwt_revoked?(payload, user)
    # Does something to check whether the JWT token is revoked for given user
  end
  
  def self.revoke_jwt(payload, user)
    # Does something to revoke the JWT token for given user
  end
end
```

### Requesting client validation

Authentication will be refused if a client requesting to be authenticated through a token is not the same to which it was originally issued. To do so, the content of the header `JWT_AUD` (configurable via `config.aud_header`) is stored as `aud` claim. If you don't want to differentiate between clients, you don't need to provide that header.

**Important:** Be aware that this workflow is not bullet proof. In some scenarios a user can handcraft the request headers, therefore being able to impersonate any client. In such cases you could need something more robust, like an OAuth workflow with client id and client secret.

## Development

There are docker and docker-compose files configured to create a development environment for this gem. So, if you use Docker you only need to run:

`docker-compose up -d`

An then, for example:

`docker-compose exec app rspec`

This gem uses [overcommit](https://github.com/brigade/overcommit) to execute some code review engines. If you submit a pull request, it will be executed in the CI process. In order to set it up, you need to do:

```ruby
bundle install --gemfile=.overcommit_gems.rb
overcommit --sign
overcommit --run # To test if it works
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/waiting-for-dev/warden-jwt_auth. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Release Policy

`warden-jwt_auth` follows the principles of [semantic versioning](http://semver.org/).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
