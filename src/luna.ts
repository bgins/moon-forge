import { AudioContext } from 'standardized-audio-context';

export class Luna {
    run(): void {
        const audioContext = new AudioContext();
        const oscillatorNode = audioContext.createOscillator();

        oscillatorNode.connect(audioContext.destination);

        oscillatorNode.start();
    }


}
