import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const showErrorToast = (component, message) => {
    const event = new ShowToastEvent({
        title: 'Error',
        message,
        variant: 'error',
        mode: 'sticky'
    });
    component.dispatchEvent(event);
};

export {
    showErrorToast
};