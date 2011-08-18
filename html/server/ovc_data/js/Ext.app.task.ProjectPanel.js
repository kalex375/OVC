/**
 * @author Kravchenko A.V.
 */
Ext.ns('Ext.app.com');

/**
 * @class Ext.app.com.ProjectTree
 * @extends Ext.tree.TreePanel
 *
 *	Панель отображает проекты в виде дерева в дополнительной панели
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype com.projecttree
 */
Ext.app.com.ProjectTree = Ext.extend(Ext.tree.TreePanel, {
    initComponent: function(){
        Ext.apply(this, {
            id: 'project-panel',
            border: true,
            title: 'Projects',
            margins: '0 0 5 5',
            cmargins: '0 0 0 0',
            lines: true,
            autoScroll: true,
            rootVisible: true,
            //autoLoad:true,
            
            root: new Ext.tree.AsyncTreeNode({
                id: 'ROOT_NODE',
                text: 'Project',
                expanded: true,
                node_type: 'root'
            
            }),
            loader: new Ext.app.com.NavigationLoader({
                dataUrl: 'p_ovc_http.get_project_tree'
            
            
            }),
            
            listeners: {
                'render': function(tp){
                    tp.getSelectionModel().on('selectionchange', function(tree, node){
                        if (node.attributes.node_type) {
                            switch (node.attributes.node_type) {
                                case 'root':
                                    this.tree.taskPanel.layout.setActiveItem(0);
                                    break;
                                case 'project':
                                    this.tree.taskPanel.layout.setActiveItem(1);
                                    break;
                                default:
                                    this.tree.taskPanel.layout.setActiveItem(0);
                                    break;
                            };
                                                    //this.tree.grid.store.setBaseParam('p_path', node.attributes.id);
                            //this.tree.grid.store.load();
                            //this.tree.taskPanel.layout.setActiveItem(1);
                            //this.tree.taskPanel.getComponent('task_grid_panel2').show;
                            //this.tree.taskPanel.doLayout;
                        
                        }
                        
                    });
                    
                },
                'load': function(node){
                    this.selectPath('/ROOT_NODE');
                }
            }
        
        });
        Ext.app.com.ProjectTree.superclass.initComponent.apply(this, arguments);
    },
    selectTask: function(id){
        this.selectPath(this.getNodeById(id).getPath())
    }
});
Ext.reg("com.projecttree", Ext.app.com.ProjectTree);

Ext.ns('Ext.app.com');
/**
 * @class Ext.app.com.ProjectPanelGrid
 * @extends Ext.Panel
 *
 *	Панель отображает проекты в гриде
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype com.projectpanelgrid
 */
Ext.app.com.ProjectPanelGrid = Ext.extend(Ext.Panel, {
    initComponent: function(){
        Ext.apply(this, {
            border: false,
            layout: 'fit',
            autoScroll: false
        });
        
        Ext.app.com.ProjectPanelGrid.superclass.initComponent.apply(this, arguments);
        
        var grid = new Ext.app.ux.FormEditGrid({
        
            id: 'grid_project',
            filterShow: true,
            textAdd: 'Add',
            tooltipAdd: 'Add project',
            textEdit: 'Edit',
            tooltipEdit: 'Edit project',
            textDelete: 'Delete',
            tooltipDelete: 'Delete project',
            nameField: 'NAME',
            objectName: 'projects',
            
            viewConfig: {
                forceFit: true
            },
            
            updater: {
                insertCommand: 'p_ovc_project.create_project',
                updateCommand: 'p_ovc_project.update_project',
                deleteCommand: 'p_ovc_project.delete_project',
                prefix: 'p_'
            },
            recordForm: {
                ignoreFields: {
                    ID: true
                },
                disabledFields: {
                    OPEN_DATE: true
                }
            },
            columnLines: true,
            store: new Ext.data.Store({
                id: 'store_project',
                url: 'p_ovc_http.get_project_table',
                // the return will be XML, so lets set up a reader
                reader: new Ext.data.XmlReader({
                    record: 'ROW',
                    id: 'ID',
                    totalProperty: "TOTALROWS",
                    fields: [{
                        name: 'ID',
                        type: 'int'
                    }, {
                        name: 'NAME',
                        type: 'string'
                    }, {
                        name: 'DESCRIPTION',
                        type: 'string'
                    }, {
                        name: 'OPEN_DATE',
                        type: 'date',
                        dateFormat: 'd.m.Y H:i:s'
                    }, {
                        name: 'CLOSE_DATE',
                        type: 'date',
                        dateFormat: 'd.m.Y H:i:s'
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
                header: "Name",
                dataIndex: 'NAME',
                width: 120,
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
                header: "Open date",
                dataIndex: 'OPEN_DATE',
                width: 60,
                sortable: true,
                editor: new Ext.form.DateField({
                    format: 'd.m.Y H:i:s'
                }),
                xtype: 'datecolumn',
                format: 'd.m.Y H:i:s'
            }, {
                header: "Close date",
                dataIndex: 'CLOSE_DATE',
                width: 60,
                sortable: true,
                editor: new Ext.form.DateField({
                    format: 'd.m.Y H:i:s'
                }),
                xtype: 'datecolumn',
                format: 'd.m.Y H:i:s'
            
            }]
        });
        this.grid = grid;
        this.add(grid);
    },
});
Ext.reg("com.projectpanelgrid", Ext.app.com.ProjectPanelGrid);


Ext.ns('Ext.app.com');
/**
 * @class Ext.app.com.ProjectPanelView
 * @extends Ext.Panel
 *
 *	Панель отображает один проект
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype com.projectpanelview
 */
Ext.app.com.ProjectPanelView = Ext.extend(Ext.Panel, {
    initComponent: function(){
        Ext.apply(this, {
            border: false,
            layout: 'fit',
            autoScroll: false
        });
        
        Ext.app.com.ProjectPanelView.superclass.initComponent.apply(this, arguments);
        
        
    },
});
Ext.reg("com.projectpanelview", Ext.app.com.ProjectPanelView);

Ext.ns('Ext.app.com');
/**
 * @class Ext.app.com.FilterPanelView
 * @extends Ext.Panel
 *
 *	Панель отображает один фильтр
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype com.filterpanelview
 */
Ext.app.com.FilterPanelView = Ext.extend(Ext.Panel, {
    initComponent: function(){
        Ext.apply(this, {
            border: false,
            layout: 'fit',
            autoScroll: false
        });
        
        Ext.app.com.FilterPanelView.superclass.initComponent.apply(this, arguments);
        
        
    },
});
Ext.reg("com.filterpanelview", Ext.app.com.FilterPanelView);


Ext.ns('Ext.app.com');
/**
 * @class Ext.app.com.FilterPanelGrid
 * @extends Ext.Panel
 *
 *	Панель отображает таблицу с фильтрами проекта
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype com.filterpanelgrid
 */
Ext.app.com.FilterPanelGrid = Ext.extend(Ext.Panel, {
    initComponent: function(){
        Ext.apply(this, {
            border: false,
            layout: 'fit',
            autoScroll: false
        });
        
        Ext.app.com.FilterPanelGrid.superclass.initComponent.apply(this, arguments);
        
        
    },
});
Ext.reg("com.filterpanelgrid", Ext.app.com.FilterPanelGrid);


Ext.ns('Ext.app.com');
/**
 * @class Ext.app.com.ObjectPanelGrid
 * @extends Ext.Panel
 *
 *	Панель отображает таблицу с объектами проекта
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype com.objectpanelgrid
 */
Ext.app.com.ObjectPanelGrid = Ext.extend(Ext.Panel, {
    initComponent: function(){
        Ext.apply(this, {
            border: false,
            layout: 'fit',
            autoScroll: false
        });
        
        Ext.app.com.ObjectPanelGrid.superclass.initComponent.apply(this, arguments);
        
        
    },
});
Ext.reg("com.objectpanelgrid", Ext.app.com.ObjectPanelGrid);

Ext.ns('Ext.app.com');
/**
 * @class Ext.app.com.ObjectPanelView
 * @extends Ext.Panel
 *
 *	Панель отображает таблицу с объектами проекта
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype com.objectpanelview
 */
Ext.app.com.ObjectPanelView = Ext.extend(Ext.Panel, {
    initComponent: function(){
        Ext.apply(this, {
            border: false,
            layout: 'fit',
            autoScroll: false
        });
        
        Ext.app.com.ObjectPanelView.superclass.initComponent.apply(this, arguments);
        
        
    },
});
Ext.reg("com.objectpanelview", Ext.app.com.ObjectPanelView);


Ext.ns('Ext.app.com');
/**
 * @class Ext.app.com.RevisionPanelView
 * @extends Ext.Panel
 *
 *	Панель отображает таблицу с объектами проекта
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype com.revisionpanelview
 */
Ext.app.com.RevisionPanelView = Ext.extend(Ext.Panel, {
    initComponent: function(){
        Ext.apply(this, {
            border: false,
            layout: 'fit',
            autoScroll: false
        });
        
        Ext.app.com.RevisionPanelView.superclass.initComponent.apply(this, arguments);
        
        
    },
});
Ext.reg("com.revisionpanelview", Ext.app.com.RevisionPanelView);

Ext.ns('Ext.app.com');
/**
 * @class Ext.app.com.RevisionPanelGrid
 * @extends Ext.Panel
 *
 *	Панель отображает таблицу с объектами проекта
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype com.revisionpanelgrid
 */
Ext.app.com.RevisionPanelGrid = Ext.extend(Ext.Panel, {
    initComponent: function(){
        Ext.apply(this, {
            border: false,
            layout: 'fit',
            autoScroll: false
        });
        
        Ext.app.com.RevisionPanelGrid.superclass.initComponent.apply(this, arguments);
        
        
    },
});
Ext.reg("com.revisionpanelgrid", Ext.app.com.RevisionPanelGrid);

Ext.ns('Ext.app.task');
/**
 * @class Ext.app.task.ProjectPanel
 * @extends Ext.app.ux.TaskPanel
 *
 * Задача Projects. Панель проектов.
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype task.projectpanel
 */
Ext.app.task.ProjectPanel = Ext.extend(Ext.app.ux.TaskPanel, {
    initComponent: function(){
        Ext.apply(this, {
            margins: '0 0 0 0',
            layout: 'card',
            activeItem: 0,
            closable: true,
            items: [{
                xtype: 'com.projectpanelgrid',
                id: 'project_grid_panel',
            }, {
                xtype: 'com.projectpanelview',
                id: 'project_view_panel',
                hidden: true
            }, {
                xtype: 'com.filterpanelgrid',
                id: 'filter_grid_panel',
                hidden: true
            }, {
                xtype: 'com.filterpanelview',
                id: 'filter_view_panel',
                hidden: true
            }, {
                xtype: 'com.objectpanelgrid',
                id: 'object_grid_panel',
                hidden: true
            }, {
                xtype: 'com.objectpanelview',
                id: 'object_view_panel',
                hidden: true
            },{
                xtype: 'com.revisionpanelgrid',
                id: 'revision_grid_panel',
                hidden: true
            }, {
                xtype: 'com.revisionpanelview',
                id: 'revision_view_panel',
                hidden: true
            }]
        });
        Ext.app.task.ProjectPanel.superclass.initComponent.apply(this, arguments);
    },
    loadPanel: function(){
    
        var grid = this.getComponent('project_grid_panel').grid;
        
        project_tree = new Ext.app.com.ProjectTree({
            grid: grid,
            taskPanel: this
        });
        
        this.iapanelAdd(project_tree)
    }
    
});

Ext.reg("task.projectpanel", Ext.app.task.ProjectPanel);
