/**
 * @author Kravchenko A.V.
 *
 */
Ext.ns('Ext.app.ux');

/**
 * @class Ext.app.ux.TaskPanel
 * @extends Ext.Panel
 *
 *	������ �����. ������������ �������������� ������ � ����� ����� Viewport
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype ux.taskpanel
 */
Ext.app.ux.TaskPanel = function(config){
	Ext.apply(this, config); 
	Ext.app.ux.TaskPanel.superclass.constructor.call(this); 
	};
	
Ext.extend(Ext.app.ux.TaskPanel, Ext.Panel, {

    /**
     * @cfg {object} ������ �� �������������� ������(������ ����������� � �����������). 
     * 				 ��������� ����������� ��� ���������� �������������� ������
     */
    apanel: '',
    
    /**
     * @cfg {object} ������ �� ���������� �������������� ������ ������
     */
    iapanel: '',
	
	/**
     * �������� ���������� ������
     * @param {object} ������ ������� ����� ������������ �� �������������� ������
     */
	iapanelAdd:function(i){
		this.iapanel = i; 
		this.apanel.add(i);
		this.apanel.doLayout(); 
	},
	
	/**
	 * Hide iapanel when tab is hide
	 * @private
	 */
	hidePanel: function(p){
		if (this.iapanel) {
			this.iapanel.hide();
		}
		
	},
	/**
	 * Show iapanel when tab is show 
	 * @private
	 */
	showPanel: function(p){
		if (this.iapanel) {
			this.iapanel.show()
		};
	},
	/**
	 * Destroy iapanel when tab is close
	 * @private
	 */
	closePanel: function(p){
		if (this.iapanel) {
			this.iapanel.destroy();
		}
	},
	
    initComponent: function(){
	
        Ext.app.ux.TaskPanel.superclass.initComponent.apply(this, arguments);
		this.on('deactivate',this.hidePanel);
		this.on('activate',this.showPanel);
		this.on('beforeclose',this.closePanel);
    }
	
});

Ext.reg("ux.taskpanel", Ext.app.ux.TaskPanel);