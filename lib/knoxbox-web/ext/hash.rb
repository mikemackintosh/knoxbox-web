class Hash

  def symbolize_keys_deep!
    self.keys.each do |k|
        ks    = k.respond_to?(:to_sym) ? k.to_sym : k
        self[ks] = self.delete k # Preserve order even when k == ks
        self[ks].symbolize_keys_deep! if self[ks].kind_of? Hash
    end
  end
  
  def to_json()
    MultiJson.dump(self)
  end

  def self.to_dotted_hash(hash, recursive_key = "")
    hash.each_with_object({}) do |(k, v), ret|
      key = recursive_key + k.to_s
      if v.is_a? Hash
        ret.merge! to_dotted_hash(v, key + ".")
      else
        ret[key] = v
      end
    end
  end

end