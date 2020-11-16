# Moon Forge

Moon Forge is an environment for creating web audio instruments for the [Lunar Rocks](https://github.com/codyshepherd/lunar-rocks) project. Luna, a subractive synth, has been implemented and more instruments are planned.

Moon Forge can be played with your keyboard or a MIDI device in Chrome and Chromium-based browsers, and keyboard in Firefox.

You can try the most recent stable build at: [moon-forge.brianginsburg.com](https://moon-forge.brianginsburg.com).

## Luna

Luna is a subtractive synth with one oscillator, amplitude envelope, one filter, filter envelope, and master gain.

Luna can be retuned to any equal division of the octave by entering the number of divisions, base frequency, and the MIDI note
at the base frequency.

## Setup

Install [Elm](https://guide.elm-lang.org/install.html) v0.19.1,[TypeScript](https://www.typescriptlang.org/index.html#download-links), and [Parcel](https://parceljs.org/getting_started.html).

Clone this repository and install its dependencies:

```
npm install
```

## Develop

To work on the application locally:

```
npm start
```

Navigate to `localhost:1234` in your web browser.

## Build

Both build commands compile to the `dist` directory.

Compile a development build without optimization.

```
npm run build:staging
```

Compile an optimized production build.

```
npm run build
```

## License

Release v0.3.0 and all earlier releases are available under MIT licnse. Releases newer that v0.3.0 will be assigned an appropriate license in due time and should be considered under copyright until that time.