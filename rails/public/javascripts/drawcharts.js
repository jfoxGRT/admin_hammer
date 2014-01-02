// some methods for showing tooltips on bar charts.. 
var previousPoint = null;

function barToolTip(event, pos, item) {

    if (item) {
        if (previousPoint != item.datapoint) {
            previousPoint = item.datapoint;
            $("#tooltip").remove();
            showTooltip(item.pageX, item.pageY, item.series.label);
        }
    } else {
        $("#tooltip").remove();
        previousPoint = null;
    }
}

function showTooltip(x, y, contents) {
    $('<div id="tooltip">' + contents + '</div>').css( {
        position: 'absolute',
        display: 'none',
        top: y + 5,
        left: x + 5,
        border: '1px solid #fdd',
        padding: '2px',
        'background-color': '#fee',
        opacity: 0.80
    }).appendTo("body").fadeIn(200);
}

//------------------------------------------------------------------------------
// function loadMore: loads data asynchronously
function loadMore(oldestEvent, oldestLoaded, data, plots, millisPer) {

    var intervalType;

    if (millisPer == 300000) {
        intervalType = "5_minute_stats";
    } else {
        intervalType = "24_hour_stats";
    }

    if (oldestEvent < oldestLoaded ) {
        var rangeStart = oldestLoaded - (millisPer * 500);
        var rangeUrl = appRoot +"/"+ intervalType + "/range/" + rangeStart + 
            "/" +oldestLoaded;

        var getMoreReq = $.ajax({ dataType: "json", url: rangeUrl })
            .success(function(jsondata) {
                oldestLoaded = rangeStart;
                unpack(jsondata, data)
                plots[1].setData(toChartData(data["summary"]["unique_agents"]));
                plots[2].setData(toChartData(data["summary"]["noop_setcred"]));
                plots[3].setData(toChartData(data["summary"]["percent_other"]));
                plots[4].setData(toChartData(data["summary"]["total"]));
                for(i=1; i<=4; i++){
                    plots[i].draw();
                }
                loadMore(oldestEvent, oldestLoaded, data, plots, millisPer);
            });
    } 
}

//------------------------------------------------------------------------------
// function getTimeString: formats a date in ISO format

function getTimeString(date) {
    var month = date.getUTCMonth() + 1;
    var day = date.getUTCDate();
    var year = date.getUTCFullYear();
    var hour = parseInt(date.getUTCHours());
    var minute = parseInt(date.getUTCMinutes());

    minute = minute < 10 ? "0" +minute.toString() : minute.toString();
    hour   = hour   < 10 ? "0" +hour.toString()   : hour.toString();
    month  = month  < 10 ? "0" +month.toString()  : month.toString();
    day    = day    < 10 ? "0" +day.toString()    : day.toString();

    var dateString = year + "-" + month+"-"+day +"T"+hour+":"+minute+"Z"
    return dateString;
}

//------------------------------------------------------------------------------
// function drawCharts: this is our entry point, actually creates the plots, etc

function drawCharts(IntervalData, intervalSize, firstInterval, images) {

    var commandHash =  IntervalData["command"];
    var allCommands = {};
    var allIntervals = [];
    var millisPer = intervalSize * 1000; 

    // let's break down the number of times each command was called
    // for all time intervals

    var millis;
    var cmd;
    var plots = [];
    var highlighted = { 1: [], 2: [], 3:[], 4:[] };

    //--------------------------------------------------------------------------
    // function drawhook: called after each plot "draw"- resets the start/end 
    // displayed on top of the charts
    
    function drawhook(plot, canvas) {
        var spans = plot.getPlaceholder().parent().children();
        
        spans.filter(".date_left").html(
            getTimeString(new Date(plot.getAxes().xaxis.min))
        );

        spans.filter(".date_right").html(
            getTimeString(new Date(plot.getAxes().xaxis.max))
        );
    }

    //--------------------------------------------------------------------------
    // function drawhookHighlights: called after plot 3 redraws, this handles
    // making sure the right bars are highlighted
    
    function drawhookHighlight(plot, canvas) {
        plot.unhighlight();
        for (var i = 0; i < highlighted[3].length; i++) {
            plots[3].highlight(0,highlighted[3][i]);
        }
        plot.clearSelection(true);
        drawhook(plot, canvas);
    }
    
    for (millis in commandHash) {
        allIntervals.push(millis);
        
        for (cmd in commandHash[millis]) {
            if (allCommands[cmd] === undefined) {
                allCommands[cmd] = parseInt(commandHash[millis][cmd], 10);
            } else {
                allCommands[cmd] += parseInt(commandHash[millis][cmd], 10);
            }
        }
    }
    
    allIntervals.sort();
    
    var plotDesc = {
        xaxis:  { mode: "time", 
                  min: allIntervals[allIntervals.length-1] - (millisPer * 48)},
        series: { points: {show: false}, 
                  shadowSize: 0, 
                  highlightColor: "#1E90FF",
                  bars: {show: true, barWidth: millisPer} },
        yaxis:  { min:0, zoomRange: [1,1]},
        zoom:   { amount: 4}, 
        grid:   { backgroundColor: "white" },
        hooks:  { draw: [drawhook] },
    }
    
    plots[1] = $.plot($("#chart1"),  
                      toChartData(IntervalData["summary"]["unique_agents"]),
                      plotDesc);
    
    plots[2] = $.plot($("#chart2"),
                      toChartData(IntervalData["summary"]["noop_setcred"]), 
                      plotDesc); 
    
    plots[4] = $.plot($("#chart4"),  
                      toChartData(IntervalData["summary"]["total"]), 
                      plotDesc); 
    
    plotDesc.selection = { mode : "x" };
    plotDesc.hooks = { draw: [drawhookHighlight] };
    
    plots[3] = $.plot($("#chart3"),
                      toChartData(IntervalData["summary"]["percent_other"]), 
                      plotDesc);
    
    var oldestEvent = firstInterval * 1000;
    var oldestLoaded = allIntervals[0];
    
    loadMore(oldestEvent, oldestLoaded, IntervalData, plots, millisPer);
    
    var timeout;
    
    // define a handler for clicking on the zoomout button
    
    $(".zoomout").click(function(e) {
        var chartnum = $(this).parents().eq(2).find(".chart").attr("chartnum");
        var myplot = plots[chartnum];
        var zoombtn =    $(this).parents().eq(2).find(".zoomout")
        zoombtn.attr("src",images["zoomoutdark.png"]);
        myplot.zoomOut();
        timeout = setTimeout(function() {
            zoombtn.attr("src",images["zoomoutlight.png"]);    
        }, 100 );
    });

    // define a handler for clicking on the zoomin button

    $(".zoomin").click(function(e) {
        var chartnum = $(this).parents().eq(2).find(".chart").attr("chartnum");
        var myplot = plots[chartnum];
        var zoombtn = $(this).parents().eq(2).find(".zoomin");
        zoombtn.attr("src",images["zoomindark.png"]);
        myplot.zoom();
        timeout = setTimeout(function() {
            zoombtn.attr("src",images["zoominlight.png"]);    
        }, 100 );
    });

    // define a handler for mousedown on the left scroll button

    $(".leftscroll").mousedown(function (e) {
        clearInterval(timeout);
        var chartnum = $(this).parents().eq(1).find(".chart").attr("chartnum");
        var myplot = plots[chartnum];
        var leftArrow = $(this).parents().eq(1).find(".left_arrow");

        leftArrow.attr("src", images["left_arrow_down.png"]);

        timeout = setInterval(function() {
            var selection = myplot.getSelection();
            myplot.pan({left: -10});
        }, 1 );
    });

    // define a handler for mouseup on the leftscroll button
    
    $(".leftscroll").mouseup(function (e) {
        clearInterval(timeout);
        var chartnum = $(this).parents().eq(1).find(".chart").attr("chartnum");
        var leftArrow = $(this).parents().eq(1).find(".left_arrow")
        var myplot = plots[chartnum];
        var selection = myplot.getSelection();
        leftArrow.attr("src", images["left_arrow_up.png"]);
    });

    // define a handler for mouseup on the rightscroll button
    
    $(".rightscroll").mouseup(function (e) {
        clearInterval(timeout);
        var chartnum = $(this).parents().eq(1).find(".chart").attr("chartnum");
        var rightArrow = $(this).parents().eq(1).find(".right_arrow")
        var myplot = plots[chartnum];
        rightArrow.attr("src", images["right_arrow_up.png"]);
        var selection = myplot.getSelection();
    });

    // define a handler for mousedown on the rightscroll button
    
    $(".rightscroll").mousedown(function (e) {
        clearInterval(timeout);
        var chartnum = $(this).parents().eq(1).find(".chart").attr("chartnum");
        var rightArrow = $(this).parents().eq(1).find(".right_arrow");
        var myplot = plots[chartnum];
        rightArrow.attr("src", images["right_arrow_down.png"]);
        timeout = setInterval(function() {
            var selection = myplot.getSelection();
            myplot.pan({left: +10});
        }, 1);
    });

    //--------------------------------------------------------------------------
    // function drawbar: draw the bar graph
    
    var drawBar = function(event, ranges) {
        var floor;
        var ceiling;
        var from = Math.floor(ranges.xaxis.from / (millisPer)) * millisPer;
        var to = Math.ceil(ranges.xaxis.to / (millisPer)) * millisPer;
        var sel = plots[3].getSelection();

        plots[3].unhighlight();
        sel.xaxis.from = from;
        sel.xaxis.to = to;

        var data = plots[3].getData()[0].data;

        for(var i =0; i< data.length; i++) {
            if ( parseInt(data[i][0]) > from && parseInt(data[i][0]) < to) {
                plots[3].highlight(0,i);
                highlighted[3].push(i);
            } else {
                for( var j = 0; j < highlighted[3].length; j++) {
                    if (highlighted[3][j] == i) {
                        highlighted[3].splice(j,1);
                    }
                }  
                plots[3].unhighlight(0,i);
            }
        }
        plots[3].clearSelection(true);
            
        floor = (Math.floor(ranges.xaxis.from)).toFixed(0);
        ceiling = (Math.ceil(ranges.xaxis.to)).toFixed(0);
        
        var start = new Date(parseInt(floor));

        // time range ends at *end* of interval

        var end = new Date(parseInt(ceiling) + intervalSize * 1000); 
        var startString = getTimeString(start);
        var endString = getTimeString(end);
        var rangeHtml = startString+" - "+endString;
        
        $("#bar_dates").html(rangeHtml);
        
        var intervalCommands = {};
        
        // let's break down the number of times each command was called
        // for the selected time range intervals
        
        for (millis in commandHash) {
            if (millis >= floor && millis < ceiling) {
                for (cmd in commandHash[millis]) {
                    
                    if (intervalCommands[cmd] === undefined) {
                        intervalCommands[cmd] = 
                            parseInt(commandHash[millis][cmd], 10);
                    } else {
                        intervalCommands[cmd] += 
                        parseInt(commandHash[millis][cmd], 10);
                    }
                }
            }
        }
        
        // for consistence sake, we want to include all commands in the legend, 
        // even if not in selected range, so let's add 0 values for those not in
        // the range it seems javascript objects don't have a keys method :( ?
        // so let's create an array for storing/sorting
        
        var sortedCmds = []; 
        for (cmd in allCommands) {
            sortedCmds.push(cmd);
            if (intervalCommands[cmd] === undefined) {
                intervalCommands[cmd] = 0;
            }
        }
        sortedCmds.sort();
        
        var dataPoints = [];
        var pos = 0;
        for (i = 0; i< sortedCmds.length; i++) {
            var key = sortedCmds[i];
            if(key !== "noop" && key !== "setcredentials") {
                pos +=1 ;
                dataPoints.push({ data: [ [pos, intervalCommands[key] ] ], 
                                  label: key});
            }
        }
        
        $("#removable").remove();
        
        $("#placeholder").
            replaceWith('<div id="bar" class="chart"></div>' +
                        '<div><form action="'+eventsRoot+
                        '"><span id="legend" class="chart">' +
                        '</span><span style="position:absolute; top:10px; right:40px;" >' +
                        '<input type="submit" value="See events"/>' +
                        '<input type="hidden" id="start_time" name="start_time" value="'+
                        start.valueOf()+'"/>' +
                        '<input type="hidden" id="end_time" name="end_time" value="'+
                        end.valueOf()+'"/>' +
                        '</span></form></div>');
        
        $("#bar_dates").parent().css("margin-left", "0px");
        $("#bar_dates").parent().css("width", "740px");
        $.plot($("#bar"),
               dataPoints,
               {
                   legend: {container: $("#legend"), 
                            backgroundColor: "white" },
                   xaxis: {ticks : 0},
                   yaxis: {minTickSize: 1, tickDecimals: 0, min: 0},
                   series: {bars: { show:true, fill: .75 }, },
                   selection: {mode : 'x'},
                   grid: {backgroundColor: "white",
                          hoverable: true,
                          clickable: true},
                   colors: ["#0c9df8", "#f80c4a", "#3b7238",
                            "#5a2cdc", "#fbfb10", "#0fbfb1",
                            "#1b174e", "#8c5337", "#1b431e",
                            "#8c52ba", "#418c66", "#bd3b35",
                            "#19d7af", "#1958ee", "#193343",
                            "#ef1692", "#48f692", "#efe092"]
               });


        var previousPoint = null;
        
        var selectedCommands = new Array();
        $("#legend > table > tbody > tr").each(function (index) {
            var cb = '<td><input type="checkbox" name="commands[]" value="' + 
                $(this).children('.legendLabel').text()+'"/>&nbsp</td>';
            $(cb).prependTo($(this));
        });
        $("#bar").bind("plothover", barToolTip);
        //        $("#bar").bind("plotclick", function(event, pos, item) {
        //var lbl = item.series.label;
        //console.log(JSON.stringify(pos));
        //console.log(lbl); 
        //$("#legend > table > tbody > tr > td.legendLabel").
        //filter(':contains("'+lbl+'")').
        //parent().children().children(':input').click()
        //
        //});
        //
    }

    $("#chart3").bind("plotselected", drawBar); 

}

//------------------------------------------------------------------------------
// function toChartData: stores data in format appropriate for plotting

function toChartData(data) {
    cdata = [];
    for (var d in data) {
        cdata.push([d, data[d]])
    }
    return [ cdata ]
}