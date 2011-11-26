module RCite

  # Represents one element of a citation. An element can be either some sort
  # of content, f.ex. the surname of an author, or a seperator like `" "` or
  # `", "`. This distinction is made so that one can add content and seperators
  # without knowing whether the content will actually exist, and later omit
  # seperators that are meant to seperate content that doesn't exist.
  class Element

    # @return [Symbol] The element type. Only `:sep` (for seperators) and `:con`
    #   (for content) are allowed. See {RCite::Element} for details.
    attr_accessor :type
    # @return [String] The element's content, for example an author's surname or
    #   a seperator like `", "`.
    attr_accessor :content

    def initialize(type, content)
      @type = type
      @content = content
    end

    def type=(type)
      raise "Unknown element type: #{type}" if ! [:con, :sep].include?(type)
      @type = type
    end

    def content=(content)
      @content = content.to_s
    end

    # Checks if this element is equal to `other_element`.
    #
    # @param [Element] other_element Another element.
    # @return [Boolean] `true` if `type` and `content` of the two elements
    #   are the same, `false` otherwise.
    def ==(other_element)
      if other_element.type == type && other_element.content == content
        return true
      end
      return false
    end

    # Returns a human-readable string representation of the Element.
    #
    # @return [String] A string indicating the type and content of the element.
    def to_s
      "[#{@type}]#{@content}"
    end
  end
end
