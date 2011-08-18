/**
 * @author Kravchenko A.V.
 */
Ext.ns('Ext.app.task');
/**
 * @class Ext.app.task.OVCHomePanel
 * @extends Ext.Panel
 *
 * Задача OVC Home. Панель отображается при входе в систему и показывает ее состояние.
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype task.ovchomepanel
 */
Ext.app.task.OVCHomePanel = Ext.extend(Ext.Panel, {
    initComponent: function(){
        Ext.apply(this, {
            closable: false,
            layout: 'table',
            layoutConfig: {
                columns: 2
            },
            
            items: [{
                title: 'Status',
                id: 'status_panel',
                tools: [{
                    id: 'refresh',
                    qtip: 'Refresh form Data',
                    handler: function(event, toolEl, panel){
                        panel.refreshPanel();
                    }
                }],
                width: 400,
                buttons: [{
                    text: 'Start service',
                    listeners: {
                        click: {
                            scope: this,
                            buffer: 200,
                            fn: function(btn){
                                Ext.Ajax.request({
                                    url: 'p_ovc_http.exec_command',
                                    scope: this,
                                    disableCaching: false,
                                    success: function(response, opts){
                                        try {
                                            var o = Ext.util.JSON.decode(response.responseText);
                                        } 
                                        catch (e) {
                                            Ext.app.util.showError(response.responseText, 'Cannot decode JSON object');
                                            return;
                                        }
                                        if (true !== o.success) {
                                            Ext.app.util.showError(o.errormsg, o.errors.title);
                                            return;
                                        }
                                        this.getComponent('status_panel').refreshPanel();
                                    },
                                    failure: function(response, opts){
                                    },
                                    params: {
                                        p_command: 'p_ovc_engine.start_process',
                                        p_params: ''
                                    }
                                });
                            }
                        }
                    }
                }, {
                    text: 'Stop service',
                    listeners: {
                        click: {
                            scope: this,
                            buffer: 200,
                            fn: function(btn){
                                Ext.Ajax.request({
                                    url: 'p_ovc_http.exec_command',
                                    scope: this,
                                    disableCaching: false,
                                    success: function(response, opts){
                                        try {
                                            var o = Ext.util.JSON.decode(response.responseText);
                                        } 
                                        catch (e) {
                                            Ext.app.util.showError(response.responseText, 'Cannot decode JSON object');
                                            return;
                                        }
                                        if (true !== o.success) {
                                            Ext.app.util.showError(o.errormsg, o.errors.title);
                                            return;
                                        }
                                        this.getComponent('status_panel').refreshPanel();
                                    },
                                    failure: function(response, opts){
                                    },
                                    params: {
                                        p_command: 'p_ovc_engine.stop_process',
                                        p_params: ''
                                    }
                                });
                            }
                        }
                    }
                }],
                refreshPanel: function(){
                
                    if (!this.statusTpl) {
                        Ext.Ajax.request({
                            url: '../ovc_data/status.tpl',
                            scope: this,
                            disableCaching: false,
                            success: function(response, opts){
                                this.statusTpl = new Ext.Template(response.responseText);
								this.refreshPanel();
                            },
                            failure: function(response, opts){
                            }
                        });
                        
                        
                    }
                    else {
                        Ext.Ajax.request({
                            url: 'p_ovc_http.get_status',
                            scope: this,
                            disableCaching: false,
                            success: function(response, opts){
                            
                                try {
                                    var o = Ext.util.JSON.decode(response.responseText);
                                } 
                                catch (e) {
                                    Ext.app.util.showError(response.responseText, 'Cannot decode JSON object');
                                    return;
                                }
                                if (true !== o.success) {
                                    Ext.app.util.showError(o.errormsg, o.errors.title);
                                    return;
                                }
                                this.statusTpl.overwrite(this.body, o.data);
                            },
                            failure: function(response, opts){
                            }
                        });
                    }
                    
                }
                
                
                
            }, {
                title: 'Remote',
                bodyStyle: 'padding: 15px 15px 15px 15px',
                id: 'remote_panel',
                width: 400,
                statusTpl: new Ext.Template(['  ']),
                html: 'Remote server status<br/>'
            }],
            loadPanel: function(){
                var sp = this.getComponent('status_panel');
                sp.refreshPanel();
            }
            
            
        });
        Ext.app.task.OVCHomePanel.superclass.initComponent.apply(this, arguments);
    }
    
});

Ext.reg("task.ovchomepanel", Ext.app.task.OVCHomePanel);
