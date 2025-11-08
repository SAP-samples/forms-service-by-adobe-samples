sap.ui.define([
    "sap/ui/core/Control",
    "sap/ui/layout/cssgrid/CSSGrid",
    "sap/m/ToggleButton"
],(Control, CSSGrid, ToggleButton) => {
    "use strict";

    return Control.extend("com.sap.fp.demo.cinema.ext.control.SeatBooker", {
        oSelectedButton: null,
        metadata: {
            properties: {
                row: {type: "int"},
                column: {type: "int"},
                select: {type : "string", defaultValue : ""},
                seats: {type: "any[]"}
            },
            aggregations: {
                _container: {type: "sap.ui.layout.cssgrid.CSSGrid", multiple: false, visibility: "hidden"},
            },
            events: {
                selected: {
                    parameters: {
                        seat: {type: "com.sap.fp.demo.cinema.ext.control.SeatType"}
                    }
                }
            }
        },
        setRow(iRow) {
            this.setProperty("row", iRow, true);
            this.getAggregation("_container").setGridTemplateRows(`repeat(${iRow}, 1fr)`)
        },

        setColumn(iColumn) {
            this.setProperty("column", iColumn, true);
            this.getAggregation("_container").setGridTemplateColumns(`repeat(${iColumn}, 1fr)`)
        },

        _lastSelected: null,
        
        _seatSelected(sName, oEvent) {
            if (this._lastSelected) {
                this._lastSelected.setPressed(false)
                if (this._lastSelected.getId() === oEvent.getSource().getId()) {
                    this.setProperty("select", "")
                    this.fireSelected({seat: ""});
                    this._lastSelected = null;
                    return
                }
            }
            
            this._lastSelected = oEvent.getSource();
            this.setProperty("select", sName)
            this.fireSelected({seat: sName});

        },

        setSeats(aSeats) {
            this.getAggregation("_container").removeAllItems();
            for(const oSeat of aSeats) {
                this.getAggregation("_container").addItem(new ToggleButton({
                    type: oSeat.booked ? sap.m.ButtonType.Default : sap.m.ButtonType.Emphasized,
                    icon: oSeat.booked ? "sap-icon://private" : "sap-icon://role",
                    enabled: !oSeat.booked,
                    pressed: this.getProperty("select") === oSeat.name,
                    press: this._seatSelected.bind(this, oSeat.name),
                    text: `${oSeat.name} - ${'$'.repeat(oSeat.tier)}`
                }))
            }
        },
        getSeats() {
            return this.getProperty("seats", [])
        },
        init() {
            this.setAggregation("_container", new CSSGrid({
                gridGap: "1em"
            }));
        },
        renderer(oRM, oControl) {
            oRM.openStart("div", oControl);
            oRM.class("SeatBookerContainer");
            oRM.openEnd();
            oRM.renderControl(oControl.getAggregation("_container"));
            oRM.close("div");
        }
    })
})