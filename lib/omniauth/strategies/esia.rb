require 'omniauth'

module OmniAuth
  module Strategies
    class ESIA
      include OmniAuth::Strategy
      autoload :AuthRequest,      'omniauth/strategies/esia/auth_request'
      autoload :AuthResponse,     'omniauth/strategies/esia/auth_response'
      autoload :ValidationError,  'omniauth/strategies/esia/validation_error'
      autoload :XMLSecurity,      'omniauth/strategies/esia/xml_security'

      option :name_identifier_format, "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

      def request_phase
        request = OmniAuth::Strategies::ESIA::AuthRequest.new
        redirect(request.create(options))
      end

      def callback_phase
        begin
          
          response = OmniAuth::Strategies::ESIA::AuthResponse.new(request.params['SAMLResponse'], options)
          response.settings = options

          @name_id  = response.name_id
          @attributes = response.attributes

          
          #return fail!(:invalid_ticket, 'Invalid SAML Ticket') if @name_id.nil? || @name_id.empty? || !response.valid?
          super
        rescue ArgumentError => e
          fail!(:invalid_ticket, StandardError.new('Invalid SAML Response'))
        end
      end

      uid { @name_id }

      info do
        {
          snils:  @attributes[:personSNILS],
          inn:    @attributes[:personINN],
          userid: @attributes[:userId],
          email:  @attributes[:personEMail],
          first_name:  @attributes[:firstName],
          last_name:   @attributes[:lastName],
          middle_name: @attributes[:middleName],
        }
      end

      extra { { :raw_info => @attributes } }

    end
  end
end

OmniAuth.config.add_camelization 'saml', 'SAML'
OmniAuth.config.add_camelization 'esia', 'ESIA'
