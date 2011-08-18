/**
 * @author Kravchenko A.V.
 */
Ext.ns('Ext.app.com');

/**
 * @class Ext.app.com.RegistryTree
 * @extends Ext.tree.TreePanel
 *
 *	Панель отображает реестр в виде дерева в дополнительной панели
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype com.registrytree
 */
Ext.app.com.RegistryTree = Ext.extend(Ext.tree.TreePanel, {
    initComponent: function(){
        Ext.apply(this, {
            //height: 250,
            border: false,
            title: 'Registry',
            margins: '0 0 5 5',
            cmargins: '0 0 0 0',
            lines: true,
            autoScroll: true,
            rootVisible: true,
			//autoLoad:true,
            root: new Ext.tree.AsyncTreeNode({
                id: 'ROOT_NODE',
                text: 'Root',
				expanded:true
            
            }),
            loader: new Ext.app.com.NavigationLoader({
                dataUrl: 'p_ovc_http.get_registry_tree'
				
				
            }),
            
            listeners: {
                'render': function(tp){
                    tp.getSelectionModel().on('selectionchange', function(tree, node){
                        if (node.attributes.id) {
                            this.tree.grid.store.setBaseParam('p_path', node.attributes.id);
                            this.tree.grid.store.load();
                        }
                        
                    });
                    
                },
				'load':function(node){
					  this.selectPath('/ROOT_NODE');
				}
            }
        
        });
        Ext.app.com.RegistryTree.superclass.initComponent.apply(this, arguments);
    },
    selectTask: function(id){
        this.selectPath(this.getNodeById(id).getPath())
    }
});
Ext.reg("com.registrytree", Ext.app.com.RegistryTree);


Ext.ns('Ext.app.task');
/**
 * @class Ext.app.task.RegistryPanel
 * @extends Ext.app.ux.TaskPanel
 *
 * Задача Registry. Панель реестр(параметры) системы.
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype task.registrypanel
 */
Ext.app.task.RegistryPanel = Ext.extend(Ext.app.ux.TaskPanel, {
    initComponent: function(){
        Ext.apply(this, {
            margins: '0 0 0 0',
            layout: 'fit',
            closable: true,
            items: [{
                xtype: 'panel',
                region: 'center',
                border: false,
                id: 're_grid_panel',
                layout: 'fit',
                autoScroll: false
            }]
        });
        Ext.app.task.RegistryPanel.superclass.initComponent.apply(this, arguments);
    },
    loadPanel: function(){
        var grid = new Ext.app.ux.FormEditGrid({
        
            id: 'grid_registry',
            filterShow: true,
            textAdd: 'Add',
            tooltipAdd: 'Add param',
            textEdit: 'Edit',
            tooltipEdit: 'Edit param',
            textDelete: 'Delete',
            tooltipDelete: 'Delete param',
            nameField: 'PARAM',
            objectName: 'params',
            
            viewConfig: {
                forceFit: true
            },
            
            updater: {
                updateCommand: 'p_ovc_registry.set_value',
                prefix: 'p_'
            },
            recordForm: {
                ignoreFields: {
                    PATH: true,
                    DESCRIPTION: true,
                    PATH_NAME: true,
                    READ_ONLY: true
                },
                disabledFields: {
                    PARAM: true,
                    TYPE: true
                }
            },
			columnLines: true,
            store: new Ext.data.Store({
                id: 'store_registry',
                url: 'p_ovc_http.get_registry_table',
                // the return will be XML, so lets set up a reader
                reader: new Ext.data.XmlReader({
                    record: 'ROW',
                    id: 'ID',
                    totalProperty: "TOTALROWS",
                    fields: [{
                        name: 'ID',
                        type: 'int'
                    }, {
                        name: 'PATH',
                        type: 'string'
                    }, {
                        name: 'PARAM',
                        type: 'string'
                    }, {
                        name: 'VALUE',
                        type: 'string'
                    }, {
                        name: 'DESCRIPTION',
                        type: 'string'
                    }, {
                        name: 'TYPE',
                        type: 'string'
                    }, {
                        name: 'PATH_NAME',
                        type: 'string'
                    }, {
                        name: 'READ_ONLY',
                        type: 'string'
                    }]
                }),
            }),
            // grid columns
            columns: [{
                header: "Id",
                dataIndex: 'ID',
                width: 50,
                hidden: true,
                sortable: true
            }, {
                header: "Param",
                dataIndex: 'PARAM',
                width: 120,
                sortable: true,
                editor: new Ext.form.TextField({
                    allowBlank: false,
                })
            }, {
                header: "Value",
                dataIndex: 'VALUE',
                width: 80,
                sortable: true,
                editor: new Ext.form.TextField({
                    allowBlank: true
                })
            }, {
                header: "Type",
                dataIndex: 'TYPE',
                width: 60,
                sortable: true,
                editor: new Ext.form.TextField({
                    allowBlank: false,
                })
            }, {
                header: "Description",
                dataIndex: 'DESCRIPTION',
                width: 200,
                sortable: true,
                editor: new Ext.form.TextField({
                    allowBlank: true
                })
            
            }, {
                header: "Read only",
                dataIndex: 'READ_ONLY',
                width: 50,
                sortable: true,
                editor: new Ext.form.TextField({
                    allowBlank: true
                })
            }, {
                header: "Path",
                dataIndex: 'PATH',
                hidden: true,
                width: 50,
                sortable: true
            }, {
                header: "Path name",
                hidden: true,
                dataIndex: 'PATH_NAME',
                width: 50,
                sortable: true
            
            }]
        });
        
        this.getComponent('re_grid_panel').add(grid);
        
        reg_tree = new Ext.app.com.RegistryTree({
            grid: grid
        });
        this.iapanelAdd(reg_tree)
    }
    
});

Ext.reg("task.registrypanel", Ext.app.task.RegistryPanel);
