# QRlixer - In development
[![Coverage Status](https://coveralls.io/repos/github/pdomaleczny/qrlixer/badge.svg?branch=main)](https://coveralls.io/github/pdomaleczny/qrlixer?branch=main)

QRlixer is an Elixir library for generating QR codes. It provides a simple and flexible API for creating QR codes from text input.

## Features

- Generate QR codes from text input
- Customize QR code size and error correction level
- Output QR codes as PNG images

## Installation

Add `qrlixer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:qrlixer, "~> 0.1.0"}
  ]
end
```

Then run `mix deps.get` to install the dependency.

## Usage

Here's a simple example of how to generate a QR code:

```elixir
input = "https://example.com"
options = [size: 250, error_correction: :high]

png_binary = QRlixer.generate(input, options)

File.write!("qr_code.png", png_binary)
```

This will generate a QR code for the URL "https://example.com" and save it as "qr_code.png".

### Options

- `:size` - The size of the QR code image in pixels (default: smallest size that fits the data)
- `:error_correction` - The error correction level (`:low`, `:medium`, `:quartile`, `:high`) (default: `:medium`)

## Documentation

Full documentation can be found at [https://hexdocs.pm/qrlixer](https://hexdocs.pm/qrlixer).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

- This library is based on the QR code specification ISO/IEC 18004:2015.
