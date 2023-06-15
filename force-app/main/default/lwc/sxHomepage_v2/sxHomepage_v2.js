import { LightningElement, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import sxResource from '@salesforce/resourceUrl/solutionExchange';

export default class SxHomepage1 extends LightningElement {

  @track quickGuides = [];
  @track designPrinciples = [];

  connectedCallback() {
    loadScript(this, sxResource + '/data/JSON-homepage.js').then(() => {
      this.quickGuides = window.quickGuides;
      this.designPrinciples = window.designPrinciples;
    });
  }
}