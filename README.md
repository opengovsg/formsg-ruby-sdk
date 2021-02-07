# FormSG Ruby SDK

Ruby SDK for integrating with form.gov.sg webhooks

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'formsg-sdk'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install formsg-sdk

## Usage

1. Install `libsodium` (<https://github.com/jedisct1/libsodium>) in your hosting server.
2. In Rails, add this as an initializer:

    ```ruby
    # config/initializers/formsg_sdk.rb
    
    Formsg::Sdk.configure do |config|
      config.default_public_key = "3Tt8VduXsjjd4IrpdCd7BAkdZl/vUCstu9UvTX84FWw=" # Production Public Key
      config.default_form_secret_key = "<your form's secret key>"
      config.default_post_uri = "https://example.com/submission"
    end
    ```

3. Add this in your controller method:

    ```ruby
    # apps/controllers/formsg_controller.rb
    
    class FormsgController < ApplicationController # You can use ActionController::API to avoid the CSRF token
      skip_before_action :verify_authenticity_token, :only => [: submissions]
    
      def submissions
        signature_status = Formsg::Sdk::Webhook.new.authenticate(
                             header: request.headers["HTTP_X_FORMSG_SIGNATURE"]
                           )

        if signature_status
          payload = params[:data]
          Rails.logger.info "POST params: #{payload.inspect}"
    
          result = Formsg::Sdk::Crypto.new.decrypt(data: payload)
          Rails.logger.info "Submission Result: #{result.inspect}"
          
          head :ok
        else
          Rails.logger.error "Invalid signature"
          
          head 500
        end
      end
    end 
    ```

4. Deploy your app to your hosting server.
5. Update your FormSG's Webhook Endpoint URL.
6. Test by submitting a new form.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Manual installation

1. Follow instructions at [rbnacl](https://github.com/RubyCrypto/rbnacl) on how to install the `libsodium` dependency in your development computer.

2. For MacOS, when installing `ffi`, you might run into this issue:

    >Function.c:847:17: error: implicit declaration of function 'ffi_prep_closure_loc' is invalid in C99
    
    You can fix it by adding the `--disable-system-libffi` option:
    
    ```
    gem install ffi:x.x.x -- --disable-system-libffi
    ```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/opengovsg/formsg-ruby-sdk.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
