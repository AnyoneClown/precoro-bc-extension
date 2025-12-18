page 50100 "APIV2 - Purchase Invoice Lines"
{
    PageType = API;
    Caption = 'Custom Purchase Invoice Lines';
    APIPublisher = 'custom';
    APIGroup = 'finance';
    APIVersion = 'v2.0';
    EntityName = 'purchaseInvoiceLine';
    EntitySetName = 'purchaseInvoiceLines';
    SourceTable = "Purchase Line";
    DelayedInsert = true;
    ODataKeyFields = SystemId;

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
                
                // --- FIX STARTS HERE ---
                field(documentId; HeaderId)
                {
                    Caption = 'Document Id';
                    
                    // This trigger runs IMMEDIATELY when the JSON "documentId" is read.
                    // It sets the keys before the system tries to validate account numbers.
                    trigger OnValidate()
                    var
                        PurchaseHeader: Record "Purchase Header";
                    begin
                        if PurchaseHeader.GetBySystemId(HeaderId) then begin
                            Rec."Document Type" := PurchaseHeader."Document Type";
                            Rec."Document No." := PurchaseHeader."No.";
                        end;
                    end;
                }
                // --- FIX ENDS HERE ---

                field(sequence; Rec."Line No.")
                {
                    Caption = 'Sequence';
                }
                field(lineType; Rec.Type)
                {
                    Caption = 'Line Type';
                }
                // Note: Changed from "accountNumber" to "lineObjectNumber" per previous advice,
                // but if your JSON uses "accountNumber", keep "accountNumber" here.
                field(accountNumber; Rec."No.") 
                {
                    Caption = 'Account or Item Number';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(description2; Rec."Description 2")
                {
                    Caption = 'Description 2';
                }
                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit Of Measure Code';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(directUnitCost; Rec."Direct Unit Cost")
                {
                    Caption = 'Direct Unit Cost';
                }
                field(lineDiscountPercent; Rec."Line Discount %")
                {
                    Caption = 'Line Discount %';
                }
                field(lineDiscountAmount; Rec."Line Discount Amount")
                {
                    Caption = 'Line Discount Amount';
                }
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount Excluding Tax';
                    Editable = false; 
                }
                field(amountIncludingTax; Rec."Amount Including VAT")
                {
                    Caption = 'Amount Including Tax';
                    Editable = false;
                }
                field(taxPercent; Rec."VAT %")
                {
                    Caption = 'Tax Percent';
                }
                
                // --- CUSTOM WHT FIELDS ---
                field(irpfTaxPercent; Rec."IRPF Withholding Tax %")
                {
                    Caption = 'IRPF Withholding Tax %';
                }
                field(irpfTaxAmount; Rec."IRPF Withholding Tax amt.")
                {
                    Caption = 'IRPF Withholding Tax Amount';
                    Editable = false; 
                }
                field(irpfCadastralRef; Rec."Cadastral Reference")
                {
                    Caption = 'Cadastral Reference';
                }
            }
        }
    }

    var
        HeaderId: Guid;

    // We keep this as a fallback, but the OnValidate above does the heavy lifting now.
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if not IsNullGuid(HeaderId) then begin
            if PurchaseHeader.GetBySystemId(HeaderId) then begin
                Rec."Document Type" := PurchaseHeader."Document Type";
                Rec."Document No." := PurchaseHeader."No.";
            end;
        end;
    end;

    trigger OnAfterGetRecord()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if PurchaseHeader.Get(Rec."Document Type", Rec."Document No.") then
            HeaderId := PurchaseHeader.SystemId;
    end;
}