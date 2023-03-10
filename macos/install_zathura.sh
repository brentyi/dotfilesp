#!/bin/zsh

# Install zathura for viewing PDFs.
#
# If you're here, maybe also try Evince? Forgot which one I like better.

brew tap zegervdv/zathura
brew install zathura --with-synctex
brew install zathura-pdf-poppler


# https://github.com/zegervdv/homebrew-zathura/issues/19
mkdir -p $(brew --prefix zathura)/lib/zathura
ln -s $(brew --prefix zathura-pdf-poppler)/libpdf-poppler.dylib $(brew --prefix zathura)/lib/zathura/libpdf-poppler.dylib
