module MarkdownHelper
  def render_markdown(text)
    return "" if text.blank?

    # Convert markdown to HTML using Kramdown
    raw_html = Kramdown::Document.new(text, syntax_highlighter: nil).to_html

    # Sanitize allowed tags and attributes
    sanitizer_config = Sanitize::Config.merge(
      Sanitize::Config::RELAXED,
      elements: Sanitize::Config::RELAXED[:elements] + %w[pre code table thead tbody tr th td blockquote hr del],
      attributes: Sanitize::Config::RELAXED[:attributes].merge(
        "a" => %w[href title target rel],
        "code" => %w[class],
        "th" => %w[align],
        "td" => %w[align]
      )
    )
    safe_html = Sanitize.fragment(raw_html, sanitizer_config)

    # Linkify @mentions safely
    linked_html = link_mentions(safe_html)

    linked_html.html_safe
  end

  private

  def link_mentions(html)
    html.gsub(/(^|\s)@([a-zA-Z0-9_]{3,30})/) do
      prefix = ::Regexp.last_match(1)
      username = ::Regexp.last_match(2)
      "#{prefix}<a href=\"/users/#{username}\" class=\"font-medium text-indigo-600 dark:text-indigo-400 hover:underline inline-flex items-center gap-0.5\">@#{username}</a>"
    end
  end
end
