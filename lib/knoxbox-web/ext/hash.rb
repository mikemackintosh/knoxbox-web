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

  # Perform a deep fetch into one or more nested hashes, returning the value
  #   at path or the default value if the value is nil
  #
  # @param path    [String,Symbol] a dot-separated string or symbol representing the path of nested hash keys that lead to the value
  # @param default                 a fallback value to return if the requested value is nil or non-existent
  #
  def get(path, default=nil)
    path = path.split('.') if path.is_a?(String)
    return default if path.nil? or (path.respond_to?(:empty?) and path.empty?)

  # flatten/arrayify all path components
    path = [*path]

  # stringify keys and set root to self
    root = self.stringify_keys()
    key = path.first.to_s
    rest = path[1..-1]

  # if current path component is in this hash...
    if root.has_key?(key)
    # if the value is a hash
      if root[key].is_a?(Hash)
      # return default or value if no more path components are left
        return (root[key].nil? ? default : root[key]) if rest.empty?

      # otherwise recurse into sub-hash
        return root[key].get(rest, default)

    # if the value is an array of hashes
      elsif root[key].is_a?(Array) and root[key].first.is_a?(Hash)
      # return default or value if no more path components are left
        return (root[key].nil? ? default : root[key]) if rest.empty?

      # otherwise, for each array item, recurse and return array of sub-hashes
        return root[key].collect{|v|
          v.get(rest, default)
        }.flatten()
      else
      # value is a scalar, return value or default
        return (root[key].nil? ? default : root[key])
      end
    else
    # short circuit to default
      return default
    end
  end
end