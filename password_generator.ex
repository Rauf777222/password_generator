defmodule PasswordGenerator do
  @default_min_length 8
  @default_max_length 16
  @default_separator "-"
  @symbols "!@#$%^&*"
  @numbers "0123456789"
  @uppercase "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  @lowercase "abcdefghijklmnopqrstuvwxyz"

  def main(args) do
    opts = parse_args(args)
    password = generate_password(opts)

    if file_path = opts[:file] do
      File.write!(file_path, password)
      IO.puts("Password saved to #{file_path}")
    else
      IO.puts("Generated password: #{password}")
    end
  end

  defp generate_password(opts) do
    type = opts[:type] || "chars"
    min_length = opts[:min_length] || @default_min_length
    max_length = opts[:max_length] || @default_max_length
    separator = opts[:separator] || @default_separator

    case type do
      "chars" -> generate_random_chars(opts, min_length, max_length)
      "words" -> generate_random_words(opts, min_length, max_length, separator)
      _ -> "Invalid type! Please usse 'chars' or 'words'."
    end
  end

  defp generate_random_chars(opts, min_length, max_length) do
    length = Enum.random(min_length..max_length)
    charset = build_charset(opts)

    for _ <- 1..length, do: Enum.random(charset), into: ""
  end

  defp generate_random_words(opts, min_length, max_length, separator) do
    length = Enum.random(min_length..max_length)
    selected_words = Enum.take_random(wordlist(), length)

    selected_words =
      if opts[:uppercase] do
        Enum.map(selected_words, &String.capitalize/1)
      else
        selected_words
      end

    Enum.join(selected_words, separator)
  end

  defp build_charset(opts) do
    base_charset = @lowercase
    charset =
      base_charset
      |> maybe_add(@uppercase, opts[:uppercase])
      |> maybe_add(@numbers, opts[:numbers])
      |> maybe_add(@symbols, opts[:symbols])

    String.graphemes(charset)
  end

  defp maybe_add(charset, addition, true), do: charset <> addition
  defp maybe_add(charset, _addition, false), do: charset

  defp wordlist do
    ~w(dog cat sun moon apple tree house star fish lion river boat car plane)
  end

  defp parse_args(args) do
    {parsed, _, _} =
      OptionParser.parse(args,
        switches: [
          type: :string,
          min_length: :integer,
          max_length: :integer,
          uppercase: :boolean,
          numbers: :boolean,
          symbols: :boolean,
          separator: :string,
          file: :string
        ]
      )

    Enum.into(parsed, %{})
  end
end


PasswordGenerator.main([
  "--type=chars",
  "--min-length=10",
  "--max-length=15",
  "--uppercase",
  "--numbers",
  "--symbols"
])