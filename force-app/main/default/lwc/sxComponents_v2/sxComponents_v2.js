import { LightningElement, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import sxResource from '@salesforce/resourceUrl/solutionExchange';

export default class SxComponents1 extends LightningElement {

  @track components = [];
  @track filteredComponents = [];
  @track filteredComponentsActions = [];
  @track filteredComponentsStructure = [];
  @track filteredComponentsForms = [];
  @track searchTerm;

  connectedCallback() {
    loadScript(this, sxResource + '/data/JSON-components.js').then(() => {
      this.components = window.components;
      this.components.sort((a, b) => (a.name.toLowerCase() > b.name.toLowerCase()) ? 1 : -1);
      this.filteredComponents = this.components;
      this.filteredComponentsActions = this.filteredComponents.slice(0,9);
      this.filteredComponentsStructure = this.filteredComponents.slice(10,20);
      this.filteredComponentsForms = this.filteredComponents.slice(21,-1);
    });
  }

  handleSearch(event) {
    let searchTerm = (event.target.value).toLowerCase();
    if (searchTerm.length === 0) {
      this.filteredComponents = this.components;
      this.filteredComponentsActions = this.filteredComponents.slice(0,9);
      this.filteredComponentsStructure = this.filteredComponents.slice(10,20);
      this.filteredComponentsForms = this.filteredComponents.slice(21,-1);
    } else {
      this.filterComponents(searchTerm);
    }
  }

  filterComponents(searchTerm) {
    this.filteredComponents = this.components.filter(function (item) {
      return item.name.toLowerCase().includes(searchTerm) ||
             item.description.toLowerCase().includes(searchTerm);
    });
    this.filteredComponentsActions = this.filteredComponents;
    this.filteredComponentsStructure = this.filteredComponents;
    this.filteredComponentsForms = this.filteredComponents;
  }
}