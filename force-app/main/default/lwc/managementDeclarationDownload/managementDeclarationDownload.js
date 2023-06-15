import {LightningElement} from 'lwc';
import DECLARATIONTESTFILE from '@salesforce/resourceUrl/DeclarationTestFile';

export default class PdfDownloadExample extends LightningElement {
   pdfDownloadLink;

   downloadDeclaration() {
        var path = DECLARATIONTESTFILE;
        this.pdfDownloadLink = path;
    } 

   /*@wire(getPdfDownloadLink, {})
   getPdfLink({ error, data }) {
       if (data) {
           console.log('pdfDownloadLink: ' + data);
           this.pdfDownloadLink = data;
       } else {
           if(error){
               console.log('error: ', error);
           }
       }
   }*/

}