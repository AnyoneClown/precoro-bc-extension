page 50101 "APIV2 - Purchase Invoices"
{
    PageType = API;
    Caption = 'Custom Purchase Invoices';
    APIPublisher = 'custom';
    APIGroup = 'finance';
    APIVersion = 'v2.0';
    EntityName = 'purchaseInvoice';
    EntitySetName = 'purchaseInvoices';
    SourceTable = "Purchase Header";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    
    // Filter to show only Invoices
    SourceTableView = where("Document Type" = const(Invoice));

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'No';
                }
                field(vendorNumber; Rec."Buy-from Vendor No.")
                {
                    Caption = 'Vendor No';
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(vendorInvoiceNo; Rec."Vendor Invoice No.")
                {
                    Caption = 'Vendor Invoice No';
                }

                // --- FIXED PART SECTION ---
                part(purchaseInvoiceLines; "APIV2 - Purchase Invoice Lines")
                {
                    Caption = 'Lines';
                    EntityName = 'purchaseInvoiceLine';
                    EntitySetName = 'purchaseInvoiceLines';
                    
                    // FIX: Put "Document Type" FIRST.
                    // This ensures the line knows it is an INVOICE before it checks the Number.
                    SubPageLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                }
            }
        }
    }
}