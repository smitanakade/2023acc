import {api, LightningElement} from 'lwc';
import chartjs from '@salesforce/resourceUrl/ChartJS28';
import {loadScript} from 'lightning/platformResourceLoader';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import srqi_images from '@salesforce/resourceUrl/srqi_images';

const currentDate = new Date().toISOString().slice(0, 10);
const twoYearsAgo = new Date();
twoYearsAgo.setFullYear(twoYearsAgo.getFullYear() - 2);
const twoYearsAgoFormatted = twoYearsAgo.toISOString().slice(0, 10);

export default class SrqiStarRatingHistoryGraph extends LightningElement {
    @api dateData;
    @api rateData;
    @api selectedDateData;
    chartInstance;
    isChartJsInitialized;

    get labels() {
        return JSON.parse(JSON.stringify([...this.dateData, twoYearsAgoFormatted, currentDate]));
    }

    get data() {
        return JSON.parse(JSON.stringify([...this.rateData, null, null]));
    }

    getPointBackgroundColor(context) {
        if (this.labels[context.dataIndex] === this.selectedDateData) {
            return 'red';
        } else {
            return 'black';
        }
    }

    @api
    refresh() {
        if (this.chartInstance) {
            this.chartInstance.data.labels = this.labels;
            this.chartInstance.data.datasets[0].data = this.data;
            this.chartInstance.update();
            return;
        }
        const images = ['', `${srqi_images}/stars_5.svg`, `${srqi_images}/stars_4.svg`, `${srqi_images}/stars_3.svg`, `${srqi_images}/stars_2.svg`, `${srqi_images}/stars_1.svg`, '']
            .map(png => {
                const image = new Image();
                image.src = png;
                return image;
            });
        const ctx = this.template.querySelector('canvas.line-chart').getContext('2d');
        this.chartInstance = new window.Chart(ctx, {
            type: 'line',
            plugins: [{
                afterDraw: chart => {
                    const yAxis = chart.scales['y-axis-0'];
                    yAxis.ticks.forEach((value, index) => {
                        const y = yAxis.getPixelForTick(index);
                        ctx.drawImage(images[index], 10, y - 15);
                    });
                }
            }],
            data: {
                labels: this.labels,
                datasets: [{
                    fill: true,
                    lineTension: 0,
                    pointBackgroundColor: (context) => this.getPointBackgroundColor(context),
                    backgroundColor: 'rgba(54, 162, 235, 0.2)',
                    data: this.data
                }]
            },
            options: {
                legend: {
                    display: false
                },
                layout: {
                    padding: {
                        left: 120
                    }
                },
                scales: {
                    yAxes: [{
                        type: 'linear',
                        ticks: {
                            max: 6,
                            min: 0,
                            stepSize: 1,
                            callback: function (value, index) {
                                return '';
                            }
                        }
                    }],
                    xAxes: [{
                        type: 'time',
                        time: {
                            unit: 'year',
                            displayFormats: {
                                year: 'YYYY'
                            }
                        },
                        ticks: {
                            min: twoYearsAgoFormatted,
                            max: currentDate
                        }
                    }]
                }
            }
        });
        this.chartInstance.canvas.parentNode.style.height = '100%';
        this.chartInstance.canvas.parentNode.style.width = '100%';
    }

    renderedCallback() {
        if (this.isChartJsInitialized) {
            return;
        }
        this.isChartJsInitialized = true;
        Promise.all([
            loadScript(this, chartjs)
        ]).then(() => {
            this.refresh();
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading ChartJS',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
    }
}