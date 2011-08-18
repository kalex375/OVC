/**
 * @author Kravchenko A.V.
 */
Ext.ns('Ext.app.com');

/**
 * @class Ext.app.com.HistListPanel
 * @extends Ext.Panel
 *
 *	������ ���������� ������� ��������� ������� � �������
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype com.histlistpanel
 */
Ext.app.com.HistListPanel = Ext.extend(Ext.Panel, {
    initComponent: function(){
        Ext.apply(this, {
            autoScroll: false,
            layout: 'fit',
            width: 200,
            items: [{
                xtype: 'grid',
                id: 'hist_grid',
                store: new Ext.data.XmlStore({
                    autoDestroy: true,
                    storeId: 'HistoryStore',
                    
                    url: 'p_ovc_http.get_change_history_table',
                    metod: 'post',
                    record: 'ROW',
                    idPath: 'ID',
                    fields: ['ID', 'MODIFY_DATE', 'MODIFY_USER', 'MODIFY_TERMINAL', 'MODIFY_TYPE', 'IS_CURRENT', 'CAN_COMPARE']
                }),
                columnSort: false,
                sm: new Ext.grid.RowSelectionModel({
                    singleSelect: true
                }),
                emptyText: 'No history to display',
                viewConfig: {
                    forceFit: true
                },
                
                columns: [{
                    header: 'Modify time',
                    width: 110,
                    dataIndex: 'MODIFY_DATE',
                    
                    renderer: function(val, x, store){
                        if ((store.data.ID == '-1') || (store.data.IS_CURRENT == 'T')) {
                            val = '<b>' + val + '</b>'
                        }
                        
                        if (store.data.CAN_COMPARE == 'F') {
                            val = '<i>' + val + '</i>'
                        };
                        
                        return val;
                    }
                }, {
                    header: 'Modify type',
                    width: 65,
                    dataIndex: 'MODIFY_TYPE',
                    renderer: function(val, x, store){
                        if ((store.data.ID == '-1') || (store.data.IS_CURRENT == 'T')) {
                            val = '<b>' + val + '</b>'
                        }
                        
                        if (store.data.CAN_COMPARE == 'F') {
                            val = '<i>' + val + '</i>'
                        };
                        
                        return val;
                    }
                }, {
                    header: 'Can Compare',
                    width: 65,
                    dataIndex: 'CAN_COMPARE',
                    hidden: true
                
                }],
                listeners: {
                    'render': function(){
                        this.getSelectionModel().on('rowselect', function(sm, rowIdx, r){
                            var diffPanel = Ext.getCmp('diff_panel');
                            if (r.data.CAN_COMPARE == 'T' && r.data.IS_CURRENT != 'T') {
                                diffPanel.loadDiff(Ext.getCmp('history_panel').change_id, r.id);
                            }
                            else {
                                diffPanel.update('<div class="div_error_message">Can\'t compare</div>');
                            }
                            
                        })
                    }
                },
            }]
        
        });
        
        Ext.app.com.HistListPanel.superclass.initComponent.apply(this, arguments);
        
        
    }
    
});

Ext.reg("com.histlistpanel", Ext.app.com.HistListPanel);

Ext.ns('Ext.app.com');
/**
 * @class Ext.app.com.HistPanel
 * @extends Ext.Panel
 *
 *	������ ���������� ������� ��������� ������� � ��������� � �������
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype com.histpanel
 */
Ext.app.com.HistPanel = Ext.extend(Ext.Panel, {
    initComponent: function(){
        Ext.apply(this, {
            border: false,
            layout: 'border',
            items: [{
                xtype: 'com.histlistpanel',
                region: 'west'
            }, {
                id: 'diff_panel',
                region: 'center',
                autoScroll: true,
                tbar: [{
                    text: 'Options',
                    menu: new Ext.menu.Menu({
                        // these items will render as dropdown menu items when the arrow is clicked:
                        items: [{
                            text: 'Show differences only',
                            id: 'tb_showonlydiff',
                            checked: true
                        }, {
                            text: 'Ignore case',
                            id: 'tb_ignorecase',
                            checked: true
                        }, {
                            text: 'Ignore white space changes',
                            id: 'tb_ignorespace',
                            checked: true
                        }, {
                            text: 'Ignore trailing space',
                            id: 'tb_ignoretrailspace',
                            checked: true
                        }, {
                            text: 'Ignore leading space',
                            id: 'tb_ignoreleadingspace',
                            checked: true
                        }]
                    })
                
                
                }],
                loadDiff: function(p_change_id, p_prev_change_id){
                    this.load({
                        url: 'p_ovc_http.get_change_diff_source',
                        params: {
                            p_change_id: p_change_id,
                            p_prev_change_id: p_prev_change_id,
                            p_only_diff: Ext.getCmp('tb_showonlydiff').checked ? 'T' : 'F',
                            p_ignore_case: Ext.getCmp('tb_ignorecase').checked ? 'T' : 'F',
                            p_ignore_space: Ext.getCmp('tb_ignorespace').checked ? 'T' : 'F',
                            p_ignore_trailing_space: Ext.getCmp('tb_ignoretrailspace').checked ? 'T' : 'F',
                            p_ignore_leading_space: Ext.getCmp('tb_ignoreleadingspace').checked ? 'T' : 'F'
                        
                        }, // or a URL encoded string
                        callback: function(){
                            SyntaxHighlighter.highlight();
                        },
                        discardUrl: false,
                        nocache: false,
                        text: 'Loading...',
                        timeout: 30,
                        scripts: false
                    });
                }
            }],
            refreshPanel: function(row){
                if (row) {
                    var histGrid = Ext.getCmp('hist_grid');
                    histGrid.getStore().load({
                        params: {
                            p_change_id: row.id
                        }
                    });
                    this.change_id = row.id;
                }
            }
        });
        Ext.app.com.HistPanel.superclass.initComponent.apply(this, arguments);
    }
});

Ext.reg("com.histpanel", Ext.app.com.HistPanel);

/**
 * @class Ext.app.com.TimeLineViewPanel
 * @extends Ext.TabPanel
 *
 *	������ ��������� ��������� ���������� �� ��������� � ��
 *
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype com.timelineviewpanel
 */
Ext.app.com.TimeLineViewPanel = Ext.extend(Ext.TabPanel, {
    initComponent: function(){
        Ext.apply(this, {
            margins: '0 5 5 0',
            resizeTabs: true,
            minTabWidth: 80,
            tabWidth: 80,
            listeners: {
                'tabchange': function(tp, tab){
                    tab.refreshPanel(this.selrow);
                }
            },
            
            height: 300,
            region: 'south',
            split: true,
            collapseMode: 'mini',
            
            items: [{
                xtype: 'panel',
                title: 'Info',
                iconCls: 'icon_information',
                id: 'info_panel',
                border: false,
                infoTpl: new Ext.Template(['<div class="InfoPanel"><br/>', 'Modify type: {MODIFY_TYPE}<br/>', 'Object name: <b>{OBJ_NAME}</b><br/>', 'Object owner: {OBJ_OWNER}<br/>', 'Modify date: <i>{MODIFY_DATE}</i><br/>', 'Modify user: {MODIFY_USER}<br/>', 'Modify terminal: {MODIFY_TERMINAL}<br/>', 'Modify OS user: {MODIFY_OS_USER}<br/>', 'Revision code: {REVISION_CODE}<br/>', 'Revision code: <p>{REVISION_DESC}</p><br/></div>']),
                refreshPanel: function(row){
                    if (row) {
                        this.infoTpl.overwrite(this.body, row.data);
                    }
                }
            }, {
                xtype: 'panel',
                title: 'Source',
                iconCls: 'icon_application_view_list',
                id: 'source_panel',
                border: false,
                autoScroll: true,
                refreshPanel: function(row){
                    if (row) {
                        this.load({
                            url: 'p_ovc_http.get_change_source',
                            params: {
                                p_change_id: row.id
                            },
                            callback: function(){
                                SyntaxHighlighter.highlight();
                                this.doLayout;
                            },
                            discardUrl: false,
                            nocache: false,
                            text: 'Loading...',
                            timeout: 30,
                            scripts: false
                        });
                    }
                }
            }, {
                xtype: 'com.histpanel',
                title: 'History',
                iconCls: 'icon_application_view_list',
                id: 'history_panel'
            }],
        });
        Ext.app.com.TimeLineViewPanel.superclass.initComponent.apply(this, arguments);
    }
});

Ext.reg("com.timelineviewpanel", Ext.app.com.TimeLineViewPanel);

Ext.ns('Ext.app.task');
/**
 * @class Ext.app.task.TimelinePanel
 * @extends Ext.app.ux.TaskPanel
 *
 *	������ Timeline. ���������� ������� � ��
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype task.timelinepanel
 */
Ext.app.task.TimelinePanel = Ext.extend(Ext.app.ux.TaskPanel, {
    initComponent: function(){
        Ext.apply(this, {
            margins: '0 0 0 0',
            layout: 'border',
            closable: true,
            items: [{
                xtype: 'panel',
                region: 'center',
                border: false,
                id: 'tl_grid-panel',
                layout: 'fit',
                autoScroll: false
            }, {
                xtype: 'com.timelineviewpanel',
                id: 'tl_view_panel',
            }],
            loadPanel: function(){
            
                this.TimeLifeStore = new Ext.data.Store({
                    id: 'store_timelife',
                    url: 'p_ovc_http.get_timelife_table',
                    listeners: {
                        'exception': function(dp, typ, act, opt, res){
                            if (typ == 'response') {
                                Ext.app.util.showError(res.responseText)
                            }
                            
                            if (typ == 'remote') {
                                Ext.Msg.alert(typ, res.responseText)
                            }
                        }
                    },
                    reader: new Ext.data.XmlReader({
                        record: 'ROW',
                        id: 'ID',
                        totalProperty: "TOTALROWS",
                        fields: [{
                            name: 'ID',
                            type: 'int'
                        }, {
                            name: 'OBJ_TYPE',
                            type: 'string'
                        }, {
                            name: 'OBJ_OWNER',
                            type: 'string'
                        }, {
                            name: 'MODIFY_DATE',
                            type: 'date',
                            dateFormat: 'd.m.Y H:i:s'
                        }, {
                            name: 'MODIFY_USER',
                            type: 'string'
                        }, {
                            name: 'OBJ_NAME',
                            type: 'string'
                        }, {
                            name: 'MODIFY_TERMINAL',
                            type: 'string'
                        }, {
                            name: 'MODIFY_OS_USER',
                            type: 'string'
                        }, {
                            name: 'MODIFY_TYPE',
                            type: 'string'
                        }, {
                            name: 'REVISION_ID',
                            type: 'int'
                        }, {
                            name: 'REVISION_CODE',
                            type: 'string'
                        }, {
                            name: 'REVISION_DESC'
                        }]
                    })
                });
                
                this.TimeLifeStore.setBaseParam('p_hide_alter', 'T');
                
                this.TimeLifeStore.load();
                
                this.TimeLineGrid = new Ext.app.ux.FilterGrid({
                    store: this.TimeLifeStore,
                    viewConfig: {
                        forceFit: true
                    },
                    columns: [{
                        header: "Id",
                        dataIndex: 'ID',
                        width: 50,
                        hidden: true,
                        sortable: true,
                        
                        editor: new Ext.form.NumberField({
                            allowBlank: false,
                            allowDecimals: false,
                            allowNegative: false
                        })
                    }, {
                        header: "Modify date",
                        dataIndex: 'MODIFY_DATE',
                        width: 110,
                        sortable: true,
                        editor: new Ext.form.DateField({
                            format: 'd.m.Y H:i:s'
                        }),
                        xtype: 'datecolumn',
                        format: 'd.m.Y H:i:s'
                    }, {
                        header: "Modify type",
                        dataIndex: 'MODIFY_TYPE',
                        width: 80,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: false,
                        })
                    }, {
                        header: "Object name",
                        dataIndex: 'OBJ_NAME',
                        width: 150,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: false,
                        })
                    }, {
                        header: "Object type",
                        dataIndex: 'OBJ_TYPE',
                        width: 100,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: false,
                        })
                    }, {
                        header: "Object owner",
                        dataIndex: 'OBJ_OWNER',
                        width: 100,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: false,
                        })
                    }, {
                        header: "Modify user",
                        dataIndex: 'MODIFY_USER',
                        width: 100,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: false,
                        })
                    }, {
                        header: "Modify terminal",
                        dataIndex: 'MODIFY_TERMINAL',
                        width: 100,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: false,
                        })
                    }, {
                        header: "Modify OS user",
                        dataIndex: 'MODIFY_OS_USER',
                        width: 100,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: false,
                        })
                    }],
                    // paging bar on the bottom
                    bbar: new Ext.PagingToolbar({
                        pageSize: 25,
                        store: this.TimeLifeStore,
                        displayInfo: true,
                        displayMsg: 'Displaying changes {0} - {1} of {2}',
                        emptyMsg: "No changes to display",
                        items: [{
                            text: 'Options',
                            menu: new Ext.menu.Menu({
                                // these items will render as dropdown menu items when the arrow is clicked:
                                items: [{
                                    text: 'Hide program ALTER',
                                    id: 'tb_hideprogalter',
                                    checked: true,
                                    store: this.TimeLifeStore,
                                    handler: function(b, e){
                                        b.store.setBaseParam('p_hide_alter', b.checked ? 'F' : 'T');
                                        b.store.load();
                                        
                                    }
                                }]
                            })
                        
                        }]
                    })
                });
                
                this.TimeLineGrid.getSelectionModel().on('rowselect', function(sm, rowIdx, r){
                    var ViewPanel = Ext.getCmp('tl_view_panel');
                    ViewPanel.selrow = r;
                    
                    var tab = ViewPanel.getComponent('info_panel');
                    if (tab) {
                        if (tab == ViewPanel.getActiveTab()) {
                            tab.refreshPanel(r);
                        }
                        else {
                            ViewPanel.setActiveTab(tab);
                        }
                    }
                });
                this.getComponent('tl_grid-panel').add(this.TimeLineGrid);
            }
        });
        Ext.app.task.TimelinePanel.superclass.initComponent.apply(this, arguments);
    }
});

Ext.reg("task.timelinepanel", Ext.app.task.TimelinePanel);
