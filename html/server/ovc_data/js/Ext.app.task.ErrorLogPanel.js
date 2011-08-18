/**
 * @author Kravchenko A.V.
 */
Ext.ns('Ext.app.task');
/**
 * @class Ext.app.task.ErrorLogPanel
 * @extends Ext.app.ux.TaskPanel
 *
 * Задача Error log. Панель отображает список ошибок произошедших в системе OVC.
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype task.errorlogpanel
 */
Ext.app.task.ErrorLogPanel = Ext.extend(Ext.app.ux.TaskPanel, {
    initComponent: function(){
        Ext.apply(this, {
            margins: '0 0 0 0',
            layout: 'border',
            closable: true,
            items: [{
                xtype: 'panel',
                region: 'center',
                border: false,
                id: 'el_grid_panel',
                layout: 'fit',
                autoScroll: false
            }],
            tbar: [{
                text: 'Command',
                menu: new Ext.menu.Menu({
                    // these items will render as dropdown menu items when the arrow is clicked:
                    items: [{
                        text: 'Clear log',
                        id: 'tb_clearlog',
                        handler: function(b, e){
                        
                            Ext.Ajax.request({
                                url: 'p_ovc_http.exec_command',
                                callback: function(options, success, response){
                                    responseObj = Ext.util.JSON.decode(response.responseText);
                                    if (responseObj.success) {
                                        Ext.getCmp('grid_errorlog').store.reload();
                                    }
                                    else {
                                        Ext.app.util.showError(responseObj.errormsg, responseObj.errors.title)
                                    }
                                },
                                
                                failure: function(response, opts){
                                    Ext.app.util.showError('Can\'t connect to server. Try again later.');
                                    
                                },
                                
                                params: {
                                    p_command: 'p_ovc_exception.clear_log',
                                    p_params: ''
                                }
                            });
                            
                        }
                        
                    }]
                })
            }],
            loadPanel: function(){
                // create the Data Store
                this.ErorLogStore = new Ext.data.Store({
                    id: 'store_errorlog',
                    url: 'p_ovc_http.get_errorlog_table',
                    // the return will be XML, so lets set up a reader
                    reader: new Ext.data.XmlReader({
                        record: 'ROW',
                        id: 'ID',
                        totalProperty: "TOTALROWS",
                        fields: [{
                            name: 'ID',
                            type: 'int'
                        }, {
                            name: 'ERROR_TIME',
                            type: 'date',
                            dateFormat: 'd.m.Y H:i:s'
                        }, {
                            name: 'CODE',
                            type: 'int'
                        }, {
                            name: 'MESSAGE',
                            type: 'string'
                        }, {
                            name: 'TERMINAL',
                            type: 'string'
                        }, {
                            name: 'OS_USER',
                            type: 'string'
                        }, {
                            name: 'CHANGE_OBJECT_ID',
                            type: 'int'
                        }]
                    })
                });
                
                this.ErorLogStore.paramNames.start = "p_start"; //by default it is "start"	
                this.ErorLogStore.paramNames.limit = "p_limit"; //by default it is "start"
                this.ErorLogStore.load({
                    params: {
                        p_start: 0,
                        p_limit: 25
                    
                    }
                });
                
                this.ErrorLogGrid = new Ext.app.ux.FilterGrid({
                    id: 'grid_errorlog',
                    store: this.ErorLogStore,
                    trackMouseOver: true,
                    loadMask: true,
                    sm: new Ext.grid.RowSelectionModel({
                        singleSelect: true
                    }),
                    viewConfig: {
                        forceFit: true
                    },
                    columnLines: true,
                    // grid columns
                    columns: [{
                        header: "Id",
                        dataIndex: 'ID',
                        width: 50,
                        hidden: true,
                        sortable: true,
                        editor: new Ext.form.NumberField({
                            allowDecimals: false,
                            allowNegative: false
                        })
                    }, {
                        header: "Time",
                        dataIndex: 'ERROR_TIME',
                        width: 110,
                        sortable: true,
                        editor: new Ext.form.DateField({
                            format: 'd.m.Y H:i:s'
                        }),
                        xtype: 'datecolumn',
                        format: 'd.m.Y H:i:s'
                    }, {
                        header: "Code",
                        dataIndex: 'CODE',
                        width: 50,
                        sortable: true,
                        editor: new Ext.form.NumberField({
                            allowDecimals: false,
                        
                        })
                    }, {
                        header: "Message",
                        dataIndex: 'MESSAGE',
                        width: 400,
                        sortable: true,
                        editor: new Ext.form.TextField({})
                    }, {
                        header: "Terminal",
                        dataIndex: 'TERMINAL',
                        width: 100,
                        sortable: true,
                        editor: new Ext.form.TextField({})
                    }, {
                        header: "OS user",
                        dataIndex: 'OS_USER',
                        width: 100,
                        sortable: true,
                        editor: new Ext.form.TextField({})
                    }]
                });
                
                
                this.ErrorLogGrid.getSelectionModel().on('rowselect', function(sm, rowIdx, r){
                
                });
                this.getComponent('el_grid_panel').add(this.ErrorLogGrid);
            }
        });
        Ext.app.task.ErrorLogPanel.superclass.initComponent.apply(this, arguments);
    }
});

Ext.reg("task.errorlogpanel", Ext.app.task.ErrorLogPanel);
