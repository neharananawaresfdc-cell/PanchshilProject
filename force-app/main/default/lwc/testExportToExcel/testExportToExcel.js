import { LightningElement, api, wire, track } from 'lwc';

export default class ExportExcel extends LightningElement {
    @track tableData = [
        { Id: '1', Name: 'Acme Corp', Industry: 'Manufacturing', Type: 'Customer' },
        { Id: '2', Name: 'Global Tech', Industry: 'Technology', Type: 'Partner' },
        { Id: '3', Name: 'Retail Pro', Industry: 'Retail', Type: 'Customer' }
    ];

    columns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Industry', fieldName: 'Industry', type: 'text' },
        { label: 'Type', fieldName: 'Type', type: 'text' }
    ];

    @api parentTableData = [];
    @api headerDataTable =[];
    @api fileName

    handleExport() {
        console.log('inside-->');
        if (this.parentTableData.length > 0) {
            this.exportAsExcel(this.headerDataTable,this.parentTableData, this.fileName); //'Outstanding Report'
        } else {
            console.log('No data available for export.');
        }
    }

    exportAsExcel(headerData, data, fileName) {
        if (!data || data.length === 0) {
            console.log('No data to export.');
            return;
        }
        // console.log('inside-->33');
        // // Convert JSON to CSV format
        // let csvContent = Object.keys(data[0]).join(',') + '\n' +
        //     data.map(row => Object.values(row).map(value => `"${value}"`).join(',')).join('\n');
        //     console.log('inside-->37');
        let csvContent = '';

        // Export headerDataTable first (summary table)
        /*if (headerData.length > 0) {
            csvContent += 'Customer Details\n';
            csvContent += Object.keys(headerData[0]).join(',') + '\n';
            csvContent += headerData.map(row => Object.values(row).map(value => `"${value}"`).join(',')).join('\n');
            csvContent += '\n\n'; // space between tables
        }*/
        if (headerData.length > 0) {
        const labels = headerData.map(item => `"${item.label}"`).join(',');
        const values = headerData.map(item => `"${item.value}"`).join(',');
        csvContent += 'Customer Details\n';
        csvContent += labels + '\n' + values + '\n\n'; // extra line for spacing
    }

        // Export parentTableData (main table)
        if (data.length > 0) {
            if(this.fileName == 'Outstanding Report'){
                csvContent += 'Outstanding Report\n';
            }else{
                csvContent += 'Customer Ledger Details\n';
            }
            
            csvContent += Object.keys(data[0]).join(',') + '\n';
            csvContent += data.map(row => Object.values(row).map(value => `"${value}"`).join(',')).join('\n');
        }
            const encodedUri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvContent);
            const link = document.createElement('a');
            link.href = encodedUri;
            link.download = `${fileName}.csv`;
        
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }
}