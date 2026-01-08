page 50101 "APIV2 - Purchase Invoices"
{
    PageType = API;
    Caption = 'Custom Purchase Invoices';
    APIPublisher = 'precoro';
    APIGroup = 'finance';
    APIVersion = 'v2.0';
    EntityName = 'purchaseInvoice';
    EntitySetName = 'purchaseInvoices';
    SourceTable = "Purchase Header";
    DelayedInsert = true;
    ODataKeyFields = SystemId;

    // Filter to show only Invoices
    SourceTableView = where("Document Type" = const(Invoice));

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                // --- SYSTEM & NUMBERING ---
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'No';
                }
                field(vendorInvoiceNumber; Rec."Vendor Invoice No.")
                {
                    Caption = 'Vendor Invoice No.';
                }

                // --- DATES ---
                field(invoiceDate; InvoiceDateVar)
                {
                    Caption = 'Invoice Date';
                    trigger OnValidate()
                    begin
                        IsInvoiceDateSet := true;
                        Rec.Validate("Document Date", InvoiceDateVar);
                    end;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date';
                }

                // --- VENDOR (BUY-FROM) ---
                field(vendorId; VendorId)
                {
                    Caption = 'Vendor Id';
                    trigger OnValidate()
                    var
                        Vendor: Record Vendor;
                    begin
                        if Vendor.GetBySystemId(VendorId) then begin
                            Rec.Validate("Buy-from Vendor No.", Vendor."No.");
                        end;
                    end;
                }
                field(vendorNumber; Rec."Buy-from Vendor No.")
                {
                    Caption = 'Vendor No.';
                }
                field(vendorName; Rec."Buy-from Vendor Name")
                {
                    Caption = 'Vendor Name';
                }

                // --- PAY-TO VENDOR ---
                field(payToVendorId; PayToVendorId)
                {
                    Caption = 'Pay-to Vendor Id';
                    trigger OnValidate()
                    var
                        Vendor: Record Vendor;
                    begin
                        if Vendor.GetBySystemId(PayToVendorId) then begin
                            Rec.Validate("Pay-to Vendor No.", Vendor."No.");
                        end;
                    end;
                }
                field(payToVendorNumber; Rec."Pay-to Vendor No.")
                {
                    Caption = 'Pay-to Vendor No.';
                }
                field(payToName; Rec."Pay-to Name")
                {
                    Caption = 'Pay-to Name';
                }
                field(payToContact; Rec."Pay-to Contact")
                {
                    Caption = 'Pay-to Contact';
                }

                // --- SHIP-TO INFO ---
                field(shipToName; Rec."Ship-to Name") { Caption = 'Ship-to Name'; }
                field(shipToContact; Rec."Ship-to Contact") { Caption = 'Ship-to Contact'; }

                // --- BUY-FROM ADDRESS ---
                field(buyFromAddressLine1; Rec."Buy-from Address") { Caption = 'Buy-from Address Line 1'; }
                field(buyFromAddressLine2; Rec."Buy-from Address 2") { Caption = 'Buy-from Address Line 2'; }
                field(buyFromCity; Rec."Buy-from City") { Caption = 'Buy-from City'; }
                field(buyFromCountry; Rec."Buy-from Country/Region Code") { Caption = 'Buy-from Country/Region Code'; }
                field(buyFromState; Rec."Buy-from County") { Caption = 'Buy-from State'; }
                field(buyFromPostCode; Rec."Buy-from Post Code") { Caption = 'Buy-from Post Code'; }

                // --- SHIP-TO ADDRESS ---
                field(shipToAddressLine1; Rec."Ship-to Address") { Caption = 'Ship-to Address Line 1'; }
                field(shipToAddressLine2; Rec."Ship-to Address 2") { Caption = 'Ship-to Address Line 2'; }
                field(shipToCity; Rec."Ship-to City") { Caption = 'Ship-to City'; }
                field(shipToCountry; Rec."Ship-to Country/Region Code") { Caption = 'Ship-to Country/Region Code'; }
                field(shipToState; Rec."Ship-to County") { Caption = 'Ship-to State'; }
                field(shipToPostCode; Rec."Ship-to Post Code") { Caption = 'Ship-to Post Code'; }

                // --- PAY-TO ADDRESS ---
                field(payToAddressLine1; Rec."Pay-to Address") { Caption = 'Pay-to Address Line 1'; }
                field(payToAddressLine2; Rec."Pay-to Address 2") { Caption = 'Pay-to Address Line 2'; }
                field(payToCity; Rec."Pay-to City") { Caption = 'Pay-to City'; }
                field(payToCountry; Rec."Pay-to Country/Region Code") { Caption = 'Pay-to Country/Region Code'; }
                field(payToState; Rec."Pay-to County") { Caption = 'Pay-to State'; }
                field(payToPostCode; Rec."Pay-to Post Code") { Caption = 'Pay-to Post Code'; }

                // --- DIMENSIONS & CURRENCY ---
                field(shortcutDimension1Code; Rec."Shortcut Dimension 1 Code") { Caption = 'Shortcut Dimension 1 Code'; }
                field(shortcutDimension2Code; Rec."Shortcut Dimension 2 Code") { Caption = 'Shortcut Dimension 2 Code'; }

                field(currencyId; CurrencyId)
                {
                    Caption = 'Currency Id';
                    trigger OnValidate()
                    var
                        Currency: Record Currency;
                    begin
                        if Currency.GetBySystemId(CurrencyId) then
                            Rec.Validate("Currency Code", Currency.Code);
                    end;
                }
                field(currencyCode; Rec."Currency Code") { Caption = 'Currency Code'; }

                // --- FINANCIALS ---
                field(pricesIncludeTax; Rec."Prices Including VAT") { Caption = 'Prices Include Tax'; }

                field(totalAmountExcludingTax; Rec.Amount)
                {
                    Caption = 'Total Amount Excluding Tax';
                    Editable = false;
                }
                field(totalTaxAmount; Rec."Amount Including VAT" - Rec.Amount)
                {
                    Caption = 'Total Tax Amount';
                    Editable = false;
                }
                field(totalAmountIncludingTax; Rec."Amount Including VAT")
                {
                    Caption = 'Total Amount Including Tax';
                    Editable = false;
                }

                field(status; Rec.Status) { Caption = 'Status'; }

                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Time';
                    Editable = false;
                }

                // --- SPECIFIC REQUEST: WHT (Withholding Tax) ---
                // Assumes "IRPF Withholding Tax Group" exists in your table/extension
                field(whtTaxCode; Rec."IRPF Withholding Tax Group")
                {
                    Caption = 'WHT Tax Group';
                }

                // --- PARTS ---
                part(purchaseInvoiceLines; "APIV2 - Purchase Invoice Lines")
                {
                    Caption = 'Lines';
                    EntityName = 'purchaseInvoiceLine';
                    EntitySetName = 'purchaseInvoiceLines';
                    // The link must ensure Document Type is handled first
                    SubPageLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                }
            }
        }
    }

    var
        VendorId: Guid;
        PayToVendorId: Guid;
        CurrencyId: Guid;
        InvoiceDateVar: Date;
        IsInvoiceDateSet: Boolean;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Insert(true);

        if IsInvoiceDateSet then begin
            Rec.Validate("Document Date", InvoiceDateVar);
            Rec.Modify(true);
        end;

        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if IsInvoiceDateSet then begin
            Rec.Validate("Document Date", InvoiceDateVar);
        end;

        Rec.Modify(true);
        exit(false);
    end;

    trigger OnAfterGetRecord()
    var
        Vendor: Record Vendor;
        Currency: Record Currency;
    begin
        InvoiceDateVar := Rec."Document Date";

        // Calculate FlowFields for Totals
        Rec.CalcFields(Amount, "Amount Including VAT", "Invoice Discount Amount");

        // Resolve Vendor Ids
        if Vendor.Get(Rec."Buy-from Vendor No.") then
            VendorId := Vendor.SystemId
        else
            Clear(VendorId);

        if Vendor.Get(Rec."Pay-to Vendor No.") then
            PayToVendorId := Vendor.SystemId
        else
            Clear(PayToVendorId);

        // Resolve Currency Id
        if Rec."Currency Code" = '' then
            Clear(CurrencyId)
        else
            if Currency.Get(Rec."Currency Code") then
                CurrencyId := Currency.SystemId;
    end;
}