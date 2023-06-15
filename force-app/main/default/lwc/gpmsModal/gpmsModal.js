import { LightningElement, api } from 'lwc';

const ESC_KEY_CODE = 27;
const ESC_KEY_STRING = 'Escape';
const TAB_KEY_CODE = 9;
const TAB_KEY_STRING = 'Tab';
const LIGHTNING_INPUT_FIELD = 'LIGHTNING-INPUT-FIELD';

export default class GpmsModal extends LightningElement {
    isFirstRender = true;
    isOpen = false;

    outsideClickListener = (e) => {
        e.stopPropagation();
        if (!this.isOpen) {
            return;
        }
        this.toggleModal();
    };

    renderedCallback() {
        this.focusGained = false;
        if (this.isFirstRender) {
            this.isFirstRender = false;
        }
    }

    @api modalHeading;
    @api modalTagline;
    @api modalSaveHandler;
    @api hideCancelButton = false;
    @api hideSaveButton = false;
    @api buttonLabel = 'Save';

    @api toggleModal() {
        this.isOpen = !this.isOpen;
        if (this.isOpen) {
            this.focusFirstChild();
        }
    }

    @api get cssClass() {
        const baseClasses = ['slds-modal'];
        baseClasses.push([this.isOpen ? 'slds-visible slds-fade-in-open' : 'slds-hidden']);
        return baseClasses.join(' ');
    }

    @api get modalAriaHidden() {
        return !this.isOpen;
    }

    closeModal(event) {
        event.stopPropagation();
        this.toggleModal();
        this.dispatchEvent(new CustomEvent('cancelclick'));
    }

    handleSave() {
        this.dispatchEvent(new CustomEvent('saveclick'));
    }

    innerClickHandler(event) {
        event.stopPropagation();
    }

    handleKeyPress(event) {
        this.innerKeyUpHandler(event);
    }

    innerKeyUpHandler(event) {
        if (event.keyCode === ESC_KEY_CODE || event.code === ESC_KEY_STRING) {
            this.toggleModal();
            this.dispatchEvent(new CustomEvent('cancelclick'));
        }
        if (event.keyCode === TAB_KEY_CODE || event.code === TAB_KEY_STRING) {
            const el = this.template.activeElement;
            let focusableElement;
            if (event.shiftKey && el && el.classList.contains('firstlink')) {
                focusableElement = !this.hideSaveButton ?
                    this.template.querySelector('button.save') :
                    this._getCloseButton();
            }
            if (el && el.classList.contains('lastLink')) {
                focusableElement = this._getCloseButton();
            }
            if (focusableElement) {
                focusableElement.focus();
            }
        }
    }

    _getCloseButton() {
        let closeButton = this.template.querySelector('button[title="Close"]');
        if (!closeButton) {
            // if no header is present, the first button is
            // always the cancel button
            closeButton = this.template.querySelector('button');
        }
        return closeButton;
    }

    _getSlotName(element) {
        let slotName = element.slot;
        while (!slotName && element.parentElement) {
            slotName = this._getSlotName(element.parentElement);
        }
        return slotName;
    }

    async focusFirstChild() {
        const children = [...this.querySelectorAll('*')];
        for (const child of children) {
            let hasBeenFocused = false;
            if (this._getSlotName(child) === 'body') {
                continue;
            }
            await this.setFocus(child).then((res) => {
                hasBeenFocused = res;
            });
            if (hasBeenFocused) {
                return;
            }
        }
        // if there is no focusable markup from slots
        // focus the first button
        const closeButton = this._getCloseButton();
        if (closeButton) {
            closeButton.focus();
        }
    }

    setFocus(el) {
        return new Promise((resolve) => {
            if (el.disabled || (el.tagName === LIGHTNING_INPUT_FIELD && el.required)) {
                return resolve(false);
            } else {
                const promiseListener = () => resolve(true);
                try {
                    el.addEventListener('focus', promiseListener);
                    el.focus && el.focus();
                    el.removeEventListener('focus', promiseListener);

                    setTimeout(() => resolve(false), 0);
                } catch (ex) {
                    return resolve(false);
                }
            }
            return resolve(false);
        });
    }
}