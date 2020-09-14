# Theming

## Fonts

Add the following to `themes.yml` brands, w/ the respective configurations:

    font_family_src: '<font-face-src>'
    font_family_name: '<name-of-font-face'
    font_weight: <font-weight>

The `font_family_src` endpoint should follow [this](http://openfontlibrary.org/face/comicdragonrunes) format.

## theme:generate

	rake theme:generate

## theme:upload

Upload generated stylesheets to S3. Takes one optional ENV ARG.

	rake theme:upload             # 'development' ENV
	rake theme:upload[test]       # 'test' ENV
	rake theme:upload[staging]    # 'staging' ENV
	rake theme:upload[production] # 'production' ENV
