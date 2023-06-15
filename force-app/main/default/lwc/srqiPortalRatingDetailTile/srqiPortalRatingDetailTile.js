import {api, LightningElement} from 'lwc';
import srqi_images from '@salesforce/resourceUrl/srqi_images';

export default class srqiPortalRatingDetailTile extends LightningElement {
    @api firstTileTitle;
    @api firstTileDateLeft;
    @api firstTileDateRight;
    @api firstTileRatingLabel;
    @api firstTileRating;
    @api secondTileTitle;
    @api secondTileDateLeft;
    @api secondTileDateRight;
    @api secondTileRatingLabel;
    @api secondTileRating;
    @api showFirstTile = false;
    @api showSecondTile = false;
    @api showSecondTileBody = false;
    @api showFirstTileBody = false;
    @api hideAllTiles = false;
    iconCurrentRating = srqi_images + '/current_rating.svg';
    iconNewRating = srqi_images + '/new_rating.svg'; 

    get firstTileRatingImage() {
        return `${srqi_images}/stars_${this.firstTileRating}.svg`;
    }

    get secondTileRatingImage() {
        return `${srqi_images}/stars_${this.secondTileRating}.svg`;
    }

    get secondTileCssClass() {
        let cssClass = 'second-tile';
        if(!this.showFirstTile) {
            cssClass += ' tile-with-right-border';
        }
        return cssClass;
    }
}