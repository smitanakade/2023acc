import { LightningElement, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import sxResource from '@salesforce/resourceUrl/solutionExchange';

export default class SxComponents extends LightningElement {

  @track components = [];
  @track filteredComponents = [];
  @track searchTerm;

  connectedCallback() {
    loadScript(this, sxResource + '/data/JSON-components.js').then(() => {
      this.components = window.components;
      this.components.sort((a, b) => (a.name.toLowerCase() > b.name.toLowerCase()) ? 1 : -1);
      this.filteredComponents = this.components;
    });
  }

  handleSearch(event) {
    let searchTerm = (event.target.value).toLowerCase();
    if (searchTerm.length === 0) {
      this.filteredComponents = this.components;
    } else {
      this.filterComponents(searchTerm);
    }
  }

  filterComponents(searchTerm) {
    this.filteredComponents = this.components.filter(function (item) {
      return item.name.toLowerCase().includes(searchTerm) ||
             item.description.toLowerCase().includes(searchTerm);
    });
  }
}