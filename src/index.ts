import { Elm } from './Main.elm';
import { Luna } from './luna.ts';

let app = Elm.Main.init({
    node: document.querySelector('main')
});

app.ports.updateAudioParam.subscribe(data => {
    console.log(JSON.stringify(data));
});

let luna = new Luna();
console.log(luna);
// luna.run()
