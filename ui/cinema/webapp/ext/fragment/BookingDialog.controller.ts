import MessageBox from "sap/m/MessageBox";
import MessageToast from "sap/m/MessageToast";
import Controller from "sap/ui/core/mvc/Controller";

export default class BookingDialog extends Controller {
  oDialog = null;
  oModel = null;

  toImg(sBase64: string) {
    return (
      "data:image/jpeg;base64," + sBase64.replace(/_/g, "/").replace(/-/g, "+")
    );
  }

  assignDialog(dialog: any) {
    this.oDialog = dialog;
  }

  async refresh() {
    //@ts-ignore
    const sServiceURL = this.oModel.getProperty("/serviceURL");
    //@ts-ignore
    const sRoomId = this.oModel.getProperty("/roomId");
    //@ts-ignore
    const sAppointmentId = this.oModel.getProperty("/scheduleId");
    //@ts-ignore
    this.oModel.setProperty("/selected", "");

    let aSeats = (
      await (
        await fetch(`${sServiceURL}Seat?$filter=Roomid eq ${sRoomId}`, {
          method: "GET",
        })
      ).json()
    ).value.map((oRoom: any) => ({
      key: oRoom.Id,
      name: oRoom.Name,
      tier: oRoom.Pricetier,
      booked: false,
    }));
    // Get all reserved seats for appointment
    const aReservedSeats = (
      await (
        await fetch(
          `${sServiceURL}Ticket?$select=Seatid&$filter=Scheduleid eq ${sAppointmentId}`,
          {
            method: "GET",
          }
        )
      ).json()
    ).value.map((oBooking: any) => oBooking.Seatid);

    // Merge all seats with active bookings
    for (let oSeat of aSeats) {
      if (aReservedSeats.includes(oSeat.key)) {
        oSeat.booked = true;
      }
    }

    // Sort seats
    // [A0 B0 C0]
    // [A1 B1 C1]
    // [A2 B2 -]
    // => A0 B0 C0 A1 B1 C1

    aSeats = aSeats.toSorted((aSeat: any, bSeat: boolean) => {
      const getColumn = (oSeat: any) => oSeat.name.substr(0, 1);
      const getRow = (oSeat: any) => parseInt(oSeat.name.substr(1));
      return (
        getRow(aSeat) - getRow(bSeat) ||
        getColumn(aSeat).localeCompare(getColumn(bSeat))
      );
    });

    //@ts-ignore
    this.oModel.setProperty("/seats", aSeats);
  }

  async initData(model: any) {
    this.oModel = model;
    await this.refresh();
    
    //@ts-ignore
    const aSeats = this.oModel.getProperty("/seats", []);
    const iColumn =
      Math.max(...aSeats.map((oSeat: any) => oSeat.name.charCodeAt(0))) -
      "A".charCodeAt(0) +
      1;
    const iRow = Math.max(...aSeats.map((oSeat: any) => oSeat.name.substr(1))) + 1;

    //@ts-ignore
    this.oModel.setProperty("/row", iRow);
    //@ts-ignore
    this.oModel.setProperty("/column", iColumn);
  }

  async onBook() {
    //@ts-ignore
    const oData = this.oModel.getData();
    if (oData.selected === "") {
      MessageBox.error("You must select a seat");
      return;
    }

    // Get seatID
    const seatId = oData.seats.find(
      (oSeat: any) => oSeat.name === oData.selected
    ).key;

    // Book Seat
    const sServiceURL = oData.serviceURL;
    try {
      const tokenResp = await fetch(`${sServiceURL}`, {
        method: "HEAD",
        headers: {
          "X-CSRF-Token": "Fetch",
        },
      });

      const resp = await fetch(`${sServiceURL}Ticket`, {
        method: "POST",
        //@ts-ignore
        headers: {
          "X-CSRF-Token": tokenResp.headers.get("X-CSRF-Token"),
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          Scheduleid: oData.scheduleId,
          Seatid: seatId,
          CurrencyCode: "EUR",
          Pricingtier: oData.personPriceTier + 1,
        }),
      });

      if (resp.status === 201) {
        MessageToast.show("Successfully booked your Seat.");
        const sTicketId = (await resp.json()).Id;
        await this.refresh();
        MessageToast.show("Ticket was booked, request queueing PDF generation");
        await this.callInstanceAction(sServiceURL, "RenderPDF", sTicketId, {})
        MessageToast.show("PDF generation is queued and will be processed shortly");
      } else {
        MessageBox.error(resp.statusText, {
          title: "Error during Service call",
        });
      }
    } catch (e: any) {
      MessageBox.error(e.message, { title: "Error during Service call" });
    }
    console.log(seatId);
  }

  async _getCSRF_Token(sServiceURL: string) {
    //@ts-ignore
    const tokenResp = await fetch(`${sServiceURL}`, {
      method: "HEAD",
      headers: {
        "X-CSRF-Token": "Fetch",
      },
    });

    return tokenResp.headers.get("X-CSRF-Token");
  }

  async callInstanceAction(sServiceURL: string, sAction: string, Id: string, oParameters: any) {
    //@ts-ignore
    try {
      const resp = await fetch(
        `${sServiceURL}Ticket(${Id})/com.sap.gateway.srvd_a2x.zcine_ticket_srvd.v0001.${sAction}`,
        {
          method: "POST",
          body: JSON.stringify(oParameters),
          //@ts-ignore
          headers: {
            "X-CSRF-Token": await this._getCSRF_Token(sServiceURL),
            "Content-Type": "application/json",
          },
        }
      );
      return resp;
    } catch (e) {
      throw e
    }
  }

  onClose() {
    //@ts-ignore
    this.oDialog.close();
  }
}
