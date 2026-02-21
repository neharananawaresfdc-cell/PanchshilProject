import { LightningElement, api, track } from 'lwc';

const ICON_COLOR_MAPPING = new Map([
    ["grey", "default"],
    ["green", "success"],
    ["orange", "warning"],
    ["red", "error"],
    ["white", "inverse"],
]);

export default class StarRatingInteractive extends LightningElement {
    @api defaultRating;
    @api totalStars = 5;
    @api size = "medium";
    @api filledColor = "orange";
    @api unfilledColor = "grey";
    @api customFilledUrl;
    @api customUnfilledUrl;
    @api editable = false;
    @track selectedRating;
    @track stars = new Array();

    @api
    set value(val) {
        try{
            this.defaultRating = val;
        this.connectedCallback();
        }
        catch(e){
            console.log('error setting value',e);
        }
        
    }

    get value() {
        return this.defaultRating;
    }

    connectedCallback() {

        this.selectedRating = this.defaultRating;
        this.stars = new Array();
        for (let i = 0; i < this.totalStars; ++i) {
            if (i < this.selectedRating) {
                this.stars.push(
                    {
                        Index: i,
                        State: ICON_COLOR_MAPPING.get(this.filledColor),
                        CustomUrl: this.customFilledUrl
                    }
                );
            } else {
                this.stars.push(
                    {
                        Index: i,
                        State: ICON_COLOR_MAPPING.get(this.unfilledColor),
                        CustomUrl: this.customUnfilledUrl
                    }
                );
            }
        }
    }

    handleRatingHover(event) {
        this.reRenderStars(1 + +event.target.getAttribute('data-id'));
    }

    handleRatingHoverOut() {
        this.reRenderStars(this.selectedRating);
    }

    handleRatingClick(event) {
        try{
        this.selectedRating = 1 + +event.target.getAttribute('data-id');

        const selectedEvent = new CustomEvent(
            'ratingclick',
            {detail: this.selectedRating}
        );
        this.dispatchEvent(selectedEvent);
        }catch(e){
            console.log('error sending rating to parent',e);
        }
    }

    reRenderStars = (numberOfFilledStars) => {
        for (let i = 0; i < this.totalStars; ++i) {
            if (i < numberOfFilledStars) {
                this.stars[i].State = ICON_COLOR_MAPPING.get(this.filledColor);
                this.stars[i].CustomUrl = this.customFilledUrl;
            }
            else {
                this.stars[i].State = ICON_COLOR_MAPPING.get(this.unfilledColor);
                this.stars[i].CustomUrl = this.customUnfilledUrl;
            }
        }
    }
}