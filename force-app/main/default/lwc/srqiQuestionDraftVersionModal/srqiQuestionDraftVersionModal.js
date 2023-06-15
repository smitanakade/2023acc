import LightningModal from 'lightning/modal';

export default class SrqiQuestionDraftVersionModal extends LightningModal {
    handleCancel() {
        this.close(false);
    }

    handleSave() {
        this.close(true);
    }
}