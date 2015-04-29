module KnoxBoxWeb
  module EasyRSA
    class << self

  # Revoke a cert
    def revoke(revoke)
      cert = ::EasyRSA::Revoke.new revoke
      crl = Pki.find_or_create_by(is: 'crl')
      if crl.content.nil?
        crl.content = cert.revoke! KnoxBoxWeb::Application.settings.ca_key
      else
        crl.content = cert.revoke! KnoxBoxWeb::Application.settings.ca_key, crl.content        
      end
      crl.save!
    end

  # Generate the certificates
    def create_cert(full_name, email)
        easyrsa = ::EasyRSA::Certificate.new(KnoxBoxWeb::Application.settings.ca_cert, 
            KnoxBoxWeb::Application.settings.ca_key, 
            full_name, 
            email
          )

      # Generate it
        g = easyrsa.generate
        [g[:key], g[:crt]]
    end   

  # Create a fingerprint helper
    def fingerprint(cert)
      unless cert.is_a? OpenSSL::X509::Certificate
        cert = OpenSSL::X509::Certificate.new cert
      end

      signature = OpenSSL::Digest::SHA256.new(cert.to_der).to_s
      signature.scan(/../).map{ |s| s.upcase }.join(":")
    end
    end
  end
end