# Moon Forge

Moon Forge is an environment for creating web audio instruments for the [Lunar
Rocks](https://github.com/codyshepherd/lunar-rocks) project.

So far, one subtractive synth has been implemented. Much work remains to make
this project a useful environment for working on arbitrary instruments and
effects.

Moon Forge works in Chrome and Chromium. Testing and fixes for Firefox are in progress.

You can try the most recent stable build at: https://brianginsburg.com/moon-forge/

## Luna

`Luna` is a subtractive synth with one oscillator, amplitude envelope, one
filter, filter envelope, and master gain. `Luna` can be played with your
computer keyboard or a MIDI controller.

`Luna` can be retuned to any equal division of the octave by selecting
`Custom Tuning` and entering the number of divisions, base frequency, and the Midi note
at the base frequency.

`Luna` may appear a bit small on the big empty `Moon Forge` canvas, but this is
by design because `Luna` will eventually be a small part of a larger application.
Zoom in your browser to get a closer look.

## Setup

Install [Elm](https://guide.elm-lang.org/install.html) v0.19,
[TypeScript](https://www.typescriptlang.org/index.html#download-links), and
[Parcel](https://parceljs.org/getting_started.html).

Most of these tools can be installed easily with `npm` which comes with any
installation of [node](https://nodejs.org/en/download/).

Clone this repository and install its dependencies:

```
npm install
```

## Develop

To work on the application locally with bundling and hot reloading:

```
parcel src/index.html
```

Navigate to `localhost:1234` in your web browser.

## Build

To produce a minified version of Moon Forge suitable for deployment:

```
parcel build src/index.html
```

This will produce a `dist/` directory with an `index.html` and static assets.
