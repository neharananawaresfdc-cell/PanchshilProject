import { LightningElement, track, api } from 'lwc';

const copyToClipboardIcon = 'utility:copy_to_clipboard';
const copyToClipboardText = 'Copy To Clipboard';

const copiedIcon = 'utility:check';
const copiedText = 'Copied!';
export default class CopyToClipboard extends LightningElement {
    @api textToCopy;
    @track toggleIconName = copyToClipboardIcon;
    @track toggleLabel = copyToClipboardText;
    // eslint-disable-next-line no-unused-vars
    handleClick(event) {
        var tmpElement = document.createElement("textarea");
        document.body.appendChild(tmpElement);
        tmpElement.value = this.textToCopy;
        tmpElement.select();
        document.execCommand("copy");
        document.body.removeChild(tmpElement);
        this.changeIconToChecked();
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(function(){
            this.changeIconToCopyToClipboard();
        }.bind(this), 900);
    }
    changeIconToChecked() {
        this.toggleIconName = copiedIcon;
        this.toggleLabel = copiedText;
    }
    changeIconToCopyToClipboard() {
        this.toggleIconName = copyToClipboardIcon;
        this.toggleLabel = copyToClipboardText;
    }
}