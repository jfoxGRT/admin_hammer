function getUTC(date, time) {
    var millis = date.valueOf();
    millis = millis +
        time.getMilliseconds() + 
        (1000 * time.getSeconds()) +
        (60000 * (time.getMinutes() - date.getTimezoneOffset() )) + 
        (3600000 * time.getHours());
    return new Date(millis);
}

function drawagenttable (){
		var getEvents;
		var windowid;

    Ext.onReady(function(){
				function gridDescriptor(id) {
						this.autoScroll = false;
            this.layout = 'fit';
            this.region = 'north';
						this.id = id;
            this.height = 150;
            this.stripeRows= true;

//					this.verticalScroller = { xtype: 'paginggridscroller' };
						this.verticalScroller = { xtype: 'gridscroller' };
						this.invalidateScrollerOnRefresh = false;
						this.disableSelection = false;
						this.viewConfig = { trackOver: false };
            this.columns = [
								{ xtype: 'rownumberer', width: 25 },
                { text: 'AgentId', sortable: false, width: 65, dataIndex: 'agentId'},
                { text: 'Timestamp', sortable: false, width: 180, dataIndex: 'timestamp_millis',
                  renderer: function(t) { return (new Date(t)).toUTCString() } },
                { text: 'Event Type', width: 115, sortable: false, dataIndex: 'eventType' },
                { text: 'Direction', width: 100, sortable: false, dataIndex: 'tokenDirection'},
                { text: 'Command ID', width: 238,  sortable: false, dataIndex: 'tokenCommandId'}
            ];
        }		

				var gridObj;
        Ext.require([
            'Ext.grid.*',
            'Ext.data.*',
            'Ext.panel.*',
            'Ext.layout.container.Border',
            'Ext.layout.container.Fit',
            'Ext.layout.container.VBox'
        ]);
        
        Ext.regModel('Event', {
            fields: [
								{ name: 'i', type: 'integer' },
                { name: '_id', type: 'string' },
                { name: 'agentId', type: 'integer' },
                { name: 'tokenCommandId', type: 'string' },
                { name: 'tokenDirection', type: 'string'},
                { name: 'eventType', type: 'string' },
                { name: 'timestamp_millis', type: 'float' }
            ]
        });
        
        var store = new Ext.data.Store({
            storeId: "eventStore",
						pageSize: 100,
						buffered: true,
						autoLoad: false,
						remoteSort: true,
						clearOnPageLoad: false,
            model: 'Event' //,
        });

        gridObj = new gridDescriptor('blank');

				var g = new Ext.grid.Panel(gridObj);

				var panelDescriptor = {
            applyTo: Ext.getDom('agent_table'),
            frame: true,
            title: 'Events (note: maximum of 100 events returned per query)',
            width: 750,
            height: 550,
						layout: { type:'vbox', align:'stretch', padding: 0 }, //new
            items: [ 
								g,
								{ xtype: 'splitter' },
                {
                    id: 'detailPanel',
                    region: 'center',
                    bodyPadding: 1,
                    autoScroll: true,
										flex: 2,
                    bodyStyle: "background: #ffffff; font-size: 11px;",
                    html: 'Please select an event to see additional details.'
                }
            ]
        }
        var p = Ext.create('Ext.panel.Panel', panelDescriptor);
        
        var command_store = Ext.create('Ext.data.Store', {
            fields: ['name'],
            data: commands 
        });
        
        getEvents = function() {

						Ext.data.StoreManager.remove('eventStore');
						store = new Ext.data.Store({
								storeId: "eventStore",
								pageSize: 100,
								buffered: true,
								autoLoad: false,
								remoteSort: true,
								model: 'Event',
						});
						
						p.remove('blank', true);
						p.remove('eventGrid', true);
						var descriptor = new gridDescriptor('eventGrid');
						descriptor.store = store;
						var grid = new Ext.grid.Panel(descriptor);
						
						p.insert(0, grid);
						grid.determineScrollbars();
						grid.getSelectionModel().on('selectionchange', function(s, e) {
								if (e.length) {
										var detailPanel = Ext.getCmp('detailPanel');
										var myurl =  appRoot + "/show/"+e[0].data._id;
										detailPanel.body.load({
												url: myurl,
												loadMask: true,
												renderer: function (loader, resp, active) {
														var pretty = JSON.stringify(JSON.parse(resp.responseText), null, 4);
														tmpl.overwrite(detailPanel.body, [pretty]);
												}
										});
								}
						});
	
            params = [];
            var incoming = Ext.getCmp('incoming_checkbox').getValue();
            var outgoing = Ext.getCmp('outgoing_checkbox').getValue();
            var agent_id = Ext.getCmp('agent_id').getValue();
            var commands = Ext.getCmp('commands').getValue();
            var start_date = Ext.getCmp('start_date').getValue();
            var start_time = Ext.getCmp('start_time').getValue();
            var end_date = Ext.getCmp('end_date').getValue();
            var end_time = Ext.getCmp('end_time').getValue();
						var d = new Date();
						windowid = d.valueOf();
						params.push("windowid="+windowid);
						
            if (incoming && !outgoing) {
                params.push("direction=INCOMING");
            } else if (!incoming && outgoing) {
                params.push("direction=OUTGOING");
            }
            
            if (commands.length >= 0) {
                params.push("commands="+commands);
            }
            
            params.push("start_time="+getUTC(start_date, start_time).valueOf());
            params.push("end_time="+getUTC(end_date, end_time).valueOf());

            if(agent_id != "") {
                params.push("agent_id="+agent_id)
            } 

            var url = appRoot+ "/search";

            if(params.length >0) {
                url += "?";
                url += params.join("&");
            }
            
            var proxy = new Ext.data.proxy.Ajax({
                model: 'Event',
                reader: { type: 'json', root: 'events', totalProperty: 'total' },
                url: url,
								simpleSortMode: true,
                type: 'ajax',
            });
            store.setProxy(proxy);
            store.load();
						// store.guaranteeRange(0,499);
        } // end of getEvents

        var start;
        var end;

        now = new Date();
        var offset = 60000 * now.getTimezoneOffset();

        if (p_start_time!=null) {
            start = new Date(p_start_time + offset);
        } else {
            start = new Date(now - (14*24*60*60*1000) + offset);
        }
        
        if(p_end_time!=null) { 
            end = new Date(p_end_time + offset) ;
        } else {
            end = new Date(now.valueOf() + offset);
        }  

        var form_panel = Ext.create('Ext.form.Panel', {
            xtype: 'fieldcontainer',
            frame: true,
            width: 750,
            items: [
                {
                    xtype: 'container',
                    layout: 'column',
                    items: [
                        { 
                            xtype: 'textfield',
                            columnWidth: .33,
                            width: 200,
                            value: p_agent_id,
                            id: 'agent_id',
                            fieldLabel: 'Agent Id',
                            labelWidth: 60,
                            labelAlign: "right",
                            
                        },
                        {
                            columnWidth: .65,
                            xtype: 'checkboxgroup',
                            fieldLabel: 'Direction',
                            labelAlign: "right",
														labelWidth: 70,
                            columns: [85,85],
                            items: [
                                {
                                    xtype: 'checkboxfield',
                                    boxLabel: 'INCOMING',
                                    name: 'incoming',
                                    checked: true,
                                    inputValue: 'incoming',
                                    id: 'incoming_checkbox'
                                },
                                {
                                    xtype: 'checkboxfield',
                                    boxLabel: 'OUTGOING',
                                    name: 'outgoing',
                                    inputValue: 'outgoing',
                                    id: 'outgoing_checkbox'
                                }
                            ]
                        },
												{
														xtype: 'combo',
														fieldLabel: 'Commands',
														multiSelect: true,
														labelAlign: "left",
														labelWidth: 60,
														displayField: 'name',
														valueField: 'name',
														value: p_command_ids,
														width: 350,
														id: 'commands',
														store: command_store,
														queryMode: 'local'
												}
                    ]
                },
								
                {
                    xtype: 'container',
                    fieldLabel: 'From: ',
                    layout: 'column',
                    items: [
                        {
                            xtype: 'datefield',
                            allowBlank: false,
                            name: 'date1',
                            value: start,
                            columnWidth: .19,
                            editable: false,
                            margin: '0 10 0 0',
                            labelWidth: 40,
														labelAlign: 'right',
														margin: 0,
                            fieldLabel: 'From',
                            id: 'start_date'
                        }, 
                        {
														margin: 0,
                            labelWidth: 0,
                            allowBlank: false,
                            xtype: 'timefield',
                            name: 'time1',
                            editable: false,
                            value: start,
                            id: 'start_time',
                            columnWidth: .11,
                            fieldLabel: '',
                        },
                        {
														margin: 0,
                            xtype: 'datefield',
                            name: 'date1',
                            value: end,
                            allowBlank: false,
                            columnWidth: .17,
                            editable: false,
														labelAlign: 'right',
                            labelWidth: 25,
                            id: 'end_date',
                            fieldLabel: 'To'
                        }, 
                        {
														margin: 0,
                            labelWidth: 0,
                            allowBlank: false,
                            xtype: 'timefield',
                            name: 'time1',
                            value: end,
                            id: 'end_time',
                            columnWidth: .11,
                            fieldLabel: '',
                        },
                        {
                            xtype: 'label',
														labelAlign: 'right',
														columnWidth: .15,
                            padding: '2 0 0 5',
														text: '(all times are UTC)'
                       },

                        { 
                            xtype: 'button',
                            columnWidth: .12,
                            editable: false,
                            margin: '0 0 0 5',
                            text: 'get event list',
                            handler: getEvents
                        }
                    ]
                }
            ],
            renderTo: Ext.getDom('direction_selector')
        }); 
        
        var tmpl = new Ext.Template("<pre> {0} </pre>");

        p.render('agent_table');

				if(p_agent_id != null || p_start_time != null) {
						getEvents();
				}
		});
}