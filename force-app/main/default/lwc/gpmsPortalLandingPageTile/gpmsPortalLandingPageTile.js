import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import styles from '@salesforce/resourceUrl/gpms_global_styles';
import gpms_images from '@salesforce/resourceUrl/gpms_images';

export default class GpmsPortalLandingPageTile extends LightningElement {

    iconArrowF = gpms_images + '/arrow_forward.svg'
    iconExternalLink = gpms_images + '/external_link.svg'

    @api hasColumns = false // Breaks list into 2 columns
    @api iconAlternativeColor = false // Tile's main icon background color. Options: aqua (default), purple
    @api iconFilename // Tile's main icon filename (including extension) from Static Resources
    @api linkExternal = false // Tile's link related icon (defaults to arrow)
    @api linkNewWindow = false // Tile's link to open in new tab/window
    @api linkUrl = '#' // Tile's link to open in new tab/window
    @api tileContent = [] // Tile's content, including heading, paragraph (optional) and list
    
    connectedCallback() {
        loadStyle(this, styles + '/variables.css');
    }

    get iconSrc() {
        return `${gpms_images}/${this.iconFilename}`;
    }

    get iconColor() {
        return this.iconAlternativeColor ? true : false;
    }

    get linkTarget() {
        return this.linkNewWindow ? '_blank' : '_self';
    }


}