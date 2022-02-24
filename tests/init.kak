source rc/comment.kak

tests %{
  test 'Toggle line comments' %{
    set-option buffer line_comment_token '#'
    toggle-comments
  } %[
    enum Color
      [Red]
      [Green]
      [Blue]

      #[def red?
      #  self == Color::Red
      #end]
    end

    [def paint(color : Color)
      case color
      when .red?
        # ...
      else
        # Unusual, but still can happen.
        raise "Unknown color: #{color}"
      end
    end

    paint "red"]
  ] %[
    enum Color
      # [Red]
      # [Green]
      # [Blue]

      [def red?
        self == Color::Red
      end]
    end

    # [def paint(color : Color)
    #   case color
    #   when .red?
    #     # ...
    #   else
    #     # Unusual, but still can happen.
    #     raise "Unknown color: #{color}"
    #   end
    # end

    # paint "red"]
  ]

  test 'Toggle block comments' %{
    set-option buffer line_comment_token
    set-option buffer block_comment_tokens '/*' '*/'
    toggle-comments
  } %[
    enum Color
      /* [Red] */
      /* [Green] */
      /* [Blue] */

      [def red?
        self == Color::Red
      end]
    end

    /* [def paint(color : Color)
      case color
      when .red?
        # ...
      else
        # Unusual, but still can happen.
        raise "Unknown color: #{color}"
      end
    end

    paint "red"] */
  ] %[
    enum Color
      [Red]
      [Green]
      [Blue]

      /* [def red?
        self == Color::Red
      end] */
    end

    [def paint(color : Color)
      case color
      when .red?
        # ...
      else
        # Unusual, but still can happen.
        raise "Unknown color: #{color}"
      end
    end

    paint "red"]
  ]
}
