import PageController from "sap/fe/core/PageController";
import Controller from "sap/ui/core/mvc/Controller";
import Dialog from "sap/m/Dialog";
import PDFViewer from "sap/m/PDFViewer";
import Fragment from "sap/ui/core/Fragment";
import JSONModel from "sap/ui/model/json/JSONModel";
import Input from "sap/m/Input";
import Button from "sap/m/Button";
import { ButtonType } from "sap/m/library";
import oEvent from "sap/ui/base/Event";
import PlanningCalendarRow from "sap/m/PlanningCalendarRow";
import Filter from "sap/ui/model/Filter";
import FilterOperator from "sap/ui/model/FilterOperator";
import CalendarAppointment from "sap/ui/unified/CalendarAppointment";
import MessageBox from "sap/m/MessageBox";

/**
 * @namespace com.sap.fp.demo.cinema.ext.main
 */
export default class Main extends PageController {
  private bookingDialog = null;
  private bookingDialogCntrl = null;
  private _pdfViewer: PDFViewer;
  private _viewModel: JSONModel;
  private oPQDialog: Dialog | null = null;
  private _bookingModel: JSONModel;
  /**
   * Called when a controller is instantiated and its View controls (if available) are already created.
   * Can be used to modify the View before it is displayed, to bind event handlers and do other one-time initialization.
   * @memberOf com.sap.fp.demo.cinema.ext.main.Main
   */
  public onInit(): void {
    super.onInit(); // needs to be called to properly initialize the page controller

    this._pdfViewer = new PDFViewer({
      isTrustedSource: true,
    });
    this._viewModel = new JSONModel();
    (this._bookingModel = new JSONModel()),
      this._viewModel.setData({
        startDate: new Date(2024, 10, 1, 9, 0, 0),
        jobs: [],
        email: "",
        pq_name: "",
      });
    this.getView()!.setModel(this._viewModel, "viewModel");
    this.getView()!.addDependent(this._pdfViewer);
    //@ts-ignore
    jQuery.sap.addUrlWhitelist("blob");
  }

  onAfterRendering(): void {}

  async onShowPDF(oEvent: any) {
    const sTicketId = oEvent
      .getSource()
      .getParent()
      .getBindingContext()
      .getProperty("Id");
    //@ts-ignore
    const sServiceURL = this.getModel().getServiceUrl();
    try {
      const resp = await this.callInstanceAction("PreviewPDF", sTicketId, {});

      /*await fetch(
        `${sServiceURL}Ticket(${sTicketId})?$select=pdf`,
        {
          method: "GET",
        }
      );*/

      const pdf = this.toPDF((await resp!.json()).pdf);
      var _pdfurl = this._base64ToBlob(pdf);

      this._pdfViewer.setSource(_pdfurl);
      this._pdfViewer.setTitle(`Ticket ${sTicketId}`);
      this._pdfViewer.open();
    } catch (e) {}
  }

  async _getCSRF_Token() {
    //@ts-ignore
    const sServiceURL = this.getModel()!.getServiceUrl();
    const tokenResp = await fetch(`${sServiceURL}`, {
      method: "HEAD",
      headers: {
        "X-CSRF-Token": "Fetch",
      },
    });

    return tokenResp.headers.get("X-CSRF-Token");
  }

  async callInstanceAction(sAction: string, Id: string, oParameters: any) {
    //@ts-ignore
    const sServiceURL = this.getModel().getServiceUrl();
    try {
      const resp = await fetch(
        `${sServiceURL}Ticket(${Id})/com.sap.gateway.srvd_a2x.zcine_ticket_srvd.v0001.${sAction}`,
        {
          method: "POST",
          body: JSON.stringify(oParameters),
          //@ts-ignore
          headers: {
            "X-CSRF-Token": await this._getCSRF_Token(),
            "Content-Type": "application/json",
          },
        }
      );
      return resp;
    } catch (e) {
      throw e;
    }
  }

  async callStaticAction(sAction: string, oParameters: any) {
    //@ts-ignore
    const sServiceURL = this.getModel().getServiceUrl();
    try {
      const resp = await fetch(
        `${sServiceURL}Ticket/com.sap.gateway.srvd_a2x.zcine_ticket_srvd.v0001.${sAction}`,
        {
          method: "POST",
          //@ts-ignore
          headers: {
            "X-CSRF-Token": await this._getCSRF_Token(),
            "Content-Type": "application/json",
          },
        }
      );
      return resp;
    } catch (e) {
      throw e;
    }
  }

  async callStaticFunction(sName: string, oParameters: any) {
    //@ts-ignore
    const sServiceURL = this.getModel().getServiceUrl();
    const sParameters = Object.entries(oParameters)
      .map(([sName, sValue]) => `${sName}=${sValue}`)
      .join(",");
    try {
      return await fetch(
        `${sServiceURL}Ticket/com.sap.gateway.srvd_a2x.zcine_ticket_srvd.v0001.${sName}(${sParameters})`
      );
    } catch (e) {
      throw e;
    }
  }

  async onSendPDFToPQ(oEvent: any) {
    if (!this.oPQDialog) {
      this.oPQDialog = new Dialog({
        title: "Send Ticket to Print Queue",
        content: new Input({
          description: "Print Queue Name",
          value: { path: "viewModel>/pq_name" },
        }),
        beginButton: new Button({
          type: ButtonType.Emphasized,
          text: "Send",
          press: async () => {
            this.oPQDialog!.close();
            //@ts-ignore
            const sTicketId = oEvent
              .getSource()
              .getParent()
              .getBindingContext()
              .getProperty("Id");
            try {
              await this.callInstanceAction(
                "SendToPQ",
                sTicketId,
                {
                  pq_name: this.getModel("viewModel")!.getProperty("/pq_name"),
                }
              );
              MessageBox.show(
                "PDF generation queued and result will be sent to Print Queue"
              );
            } catch (e) {
              //Todo
            }
          },
        }),
        endButton: new Button({
          text: "Close",
          press: () => {
            this.oPQDialog!.close();
          },
        }),
      });
      //@ts-ignore
      this.getView().addDependent(this.oPQDialog);
    }
    this.oPQDialog.open();
  }
  async onResetDemo(oEvent: any) {
    await this.callStaticAction("ResetDemo", {});
    //document.location.reload();
  }

  _base64ToBlob(pdf: any) {
    var base64EncodedPDF = pdf; // the encoded string
    var decodedPdfContent = atob(base64EncodedPDF);
    var byteArray = new Uint8Array(decodedPdfContent.length);
    for (var i = 0; i < decodedPdfContent.length; i++) {
      byteArray[i] = decodedPdfContent.charCodeAt(i);
    }
    var blob = new Blob([byteArray.buffer], { type: "application/pdf" });
    return URL.createObjectURL(blob);
  }

  toPDF(sBase64: string) {
    return sBase64.replace(/_/g, "/").replace(/-/g, "+");
  }

  toImg(sBase64: string) {
    return (
      "data:image/jpeg;base64," + sBase64.replace(/_/g, "/").replace(/-/g, "+")
    );
  }

  toDateTime(oDate: any, oTime: any) {
    if (!!oDate === false || !!oTime === false) {
      return null;
    }
    const newDate = new Date(oDate.getTime() + oTime.getTime());
    return newDate;
  }

  updateRoomCalRow(oEvent: oEvent) {
    const calRow = oEvent.getSource() as PlanningCalendarRow;
    const roomId = calRow.getBindingContext()?.getProperty("Id");
    const startDate = (this._viewModel.getProperty("/startDate") as Date)
      .toISOString()
      .substring(0, 10);
    if (roomId === undefined) {
      return;
    }

    const oFilter: Filter[] = [
      new Filter({
        filters: [
          new Filter({
            path: "Begindate",
            operator: FilterOperator.EQ,
            value1: startDate,
          }),
          new Filter({
            path: "Roomid",
            operator: FilterOperator.EQ,
            value1: roomId,
          }),
        ],
        and: true,
      }),
    ];

    const AppointMentTemplate = new CalendarAppointment({
      startDate: {
        parts: [{ path: "Begindate" }, { path: "Begintime" }],
        formatter: this.toDateTime,
      },
      endDate: {
        parts: [{ path: "Enddate" }, { path: "Endtime" }],
        formatter: this.toDateTime,
      },
      icon: { path: "Movie/Logo", formatter: this.toImg, targetType: "any" },
      title: { path: "Movie/Title" },
      text: { path: "Movie/Description" },
    });

    calRow.bindAggregation("appointments", {
      path: `/Schedule`,
      templateShareable: false,
      filters: oFilter,
      template: AppointMentTemplate,
      key: "Id",
    });
  }

  async onScheduleSelected(oEvent: any) {
    //@ts-ignore
    sap.ui.core.BusyIndicator.show();
    if (this.bookingDialog === null) {
      //@ts-ignore
      this.bookingDialogCntrl = await Controller.create({
        name: "com.sap.fp.demo.cinema.ext.fragment.BookingDialog",
      });

      //@ts-ignore
      this.bookingDialog = await Fragment.load({
        name: "com.sap.fp.demo.cinema.ext.fragment.BookingDialog",
        //@ts-ignore
        controller: this.bookingDialogCntrl,
      });
      //@ts-ignore
      this.bookingDialogCntrl.assignDialog(this.bookingDialog);
    }

    const oAppointmentBinding = oEvent
      .getParameter("appointment")
      .getBindingContext();

    //ToDo: Insert Busy dialog
    //ToDo: Error Handling

    // Calculate booked seats
    const sAppointmentId = oAppointmentBinding.getObject().Id;
    //@ts-ignore
    const sServiceURL = this.getModel().getServiceUrl();
    // Get Room for appointment
    const sRoomId = (
      await (
        await fetch(
          `${sServiceURL}Schedule(${sAppointmentId})?$select=Roomid`,
          {
            method: "GET",
          }
        )
      ).json()
    ).Roomid;
    // Get all seats for room

    this._bookingModel.setData({
      scheduleId: sAppointmentId,
      roomId: sRoomId,
      personPriceTier: 0,
      seats: [],
      row: 0,
      column: 0,
      selected: "",
      serviceURL: sServiceURL,
    });

    //@ts-ignore
    await this.bookingDialogCntrl.initData(this._bookingModel);

    if (this.bookingDialog !== null) {
      //@ts-ignore
      this.bookingDialog.setModel(this.getModel());
      //@ts-ignore
      this.bookingDialog.setModel(this._bookingModel, "bookingModel");
      //@ts-ignore
      this.bookingDialog.setBindingContext(oAppointmentBinding);
      //@ts-ignore
      this.bookingDialog.open();
    }
    //@ts-ignore
    sap.ui.core.BusyIndicator.hide();
  }

  onTicketRefresh() {
    this.getModel()!.refresh();
  }
}
