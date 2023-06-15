import { LightningElement, api } from 'lwc';
import sxStyles from '@salesforce/resourceUrl/solutionExchange';
import communityPath from '@salesforce/community/basePath';
import { NavigationMixin } from 'lightning/navigation'; // ernie

export default class SxComponentCard extends NavigationMixin(LightningElement) { // ernie - added extends NavigationMixin(LightningElement) 
  @api name;
  @api iconUrl;
  @api iconId;
  @api description;
  @api pageUrl;
  @api thumbnailUrl;

  isCardHover = false; // ernie

  get icon() {
    return `${sxStyles}`+ this.iconUrl+ '#'+ this.iconId;
  }

  get allowRedirect() {
    return this.pageUrl !== undefined && this.pageUrl.length > 0;
  }

  get url() {
    return communityPath + this.pageUrl;
  }

  get imageUrl() {
    return `${sxStyles}` +  this.thumbnailUrl
  }

  get showIcon() {
    if (this.iconUrl) {
      return true;
    }
    return false;
  }

  // ernie
  handleClick() {
    //console.log('Card was clicked!');
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
          url: this.pageUrl
      }
    });
  }

  // ernie
  handleMouseOver() {
    this.isCardHover = true;
  }

  // ernie
  handleMouseLeave() {
    this.isCardHover = false;
  }

  // ernie
  get selectedClass(){
    return this.isCardHover ? 'sx-component-card-hover' : 'sx-component-card';
  }


}