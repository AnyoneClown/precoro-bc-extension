page 50100 "APIV2 - Purchase Invoice Lines"
{
    PageType = API;
    Caption = 'Custom Purchase Invoice Lines';
    APIPublisher = 'precoro';
    APIGroup = 'finance';
    APIVersion = 'v2.0';
    EntityName = 'purchaseInvoiceLine';
    EntitySetName = 'purchaseInvoiceLines';
    SourceTable = "Purchase Line";
    DelayedInsert = true;
    ODataKeyFields = SystemId;

    SourceTableView = where("Document Type" = const(Invoice)); 

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                // --- SYSTEM IDS ---
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                
                // --- HEADER LINKING ---
                field(documentId; HeaderId)
                {
                    Caption = 'Document Id';
                    trigger OnValidate()
                    var
                        PurchaseHeader: Record "Purchase Header";
                    begin
                        if Rec."Document No." <> '' then exit; // Skip if already linked via URL
                        if PurchaseHeader.GetBySystemId(HeaderId) then begin
                            Rec.Validate("Document Type", PurchaseHeader."Document Type");
                            Rec.Validate("Document No.", PurchaseHeader."No.");
                        end;
                    end;
                }

                field(sequence; Rec."Line No.")
                {
                    Caption = 'Sequence';
                }

                // --- TYPE & NUMBER ---
                field(lineType; Rec.Type)
                {
                    Caption = 'Line Type';
                }
                field(lineObjectNumber; Rec."No.") 
                {
                    Caption = 'No.';
                }

                // --- ID LOOKUPS (Standard API Behavior) ---
                field(itemId; ItemId)
                {
                    Caption = 'Item Id';
                    trigger OnValidate()
                    var
                        Item: Record Item;
                    begin
                        if Item.GetBySystemId(ItemId) then begin
                            Rec.Validate(Type, Rec.Type::Item);
                            Rec.Validate("No.", Item."No.");
                        end;
                    end;
                }
                field(accountId; AccountId)
                {
                    Caption = 'Account Id';
                    trigger OnValidate()
                    var
                        GLAccount: Record "G/L Account";
                    begin
                        if GLAccount.GetBySystemId(AccountId) then begin
                            Rec.Validate(Type, Rec.Type::"G/L Account");
                            Rec.Validate("No.", GLAccount."No.");
                        end;
                    end;
                }

                // --- DESCRIPTION & VARIANT ---
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(itemVariantId; VariantId)
                {
                    Caption = 'Item Variant Id';
                    trigger OnValidate()
                    var
                        ItemVariant: Record "Item Variant";
                    begin
                        if ItemVariant.GetBySystemId(VariantId) then
                            Rec.Validate("Variant Code", ItemVariant.Code);
                    end;
                }

                // --- QUANTITY & UOM ---
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(unitOfMeasureId; UOMId)
                {
                    Caption = 'Unit Of Measure Id';
                    trigger OnValidate()
                    var
                        UOM: Record "Unit of Measure";
                    begin
                        if UOM.GetBySystemId(UOMId) then
                            Rec.Validate("Unit of Measure Code", UOM.Code);
                    end;
                }
                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit of Measure Code';
                }

                // --- PRICING ---
                field(unitCost; Rec."Direct Unit Cost")
                {
                    Caption = 'Unit Cost';
                }
                field(discountAmount; Rec."Line Discount Amount")
                {
                    Caption = 'Discount Amount';
                }
                field(discountPercent; Rec."Line Discount %")
                {
                    Caption = 'Discount Percent';
                }

                // --- AMOUNTS & TAX ---
                field(amountExcludingTax; Rec.Amount)
                {
                    Caption = 'Amount Excluding Tax';
                    Editable = false; 
                }
                field(amountIncludingTax; Rec."Amount Including VAT")
                {
                    Caption = 'Amount Including Tax';
                    Editable = false;
                }
                field(taxCode; Rec."VAT Prod. Posting Group")
                {
                    Caption = 'Tax Code';
                }
                field(netAmount; Rec.Amount)
                {
                    Caption = 'Net Amount';
                    Editable = false;
                }
                field(netTaxAmount; Rec."Amount Including VAT" - Rec.Amount)
                {
                    Caption = 'Net Tax Amount';
                    Editable = false;
                }
                field(netAmountIncludingTax; Rec."Amount Including VAT")
                {
                    Caption = 'Net Amount Including Tax';
                    Editable = false;
                }
                
                // --- DATES & LOCATION ---
                field(expectedReceiptDate; Rec."Expected Receipt Date")
                {
                    Caption = 'Expected Receipt Date';
                }
                field(locationId; LocationId)
                {
                    Caption = 'Location Id';
                    trigger OnValidate()
                    var
                        Location: Record Location;
                    begin
                        if Location.GetBySystemId(LocationId) then
                            Rec.Validate("Location Code", Location.Code);
                    end;
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
            }
        }
    }

    var
        HeaderId: Guid;
        ItemId: Guid;
        AccountId: Guid;
        UOMId: Guid;
        VariantId: Guid;
        LocationId: Guid;

    // --- TRIGGERS ---

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // Fallback for Flat Inserts
        if (Rec."Document No." = '') and (not IsNullGuid(HeaderId)) then begin
            if PurchaseHeader.GetBySystemId(HeaderId) then begin
                Rec.Validate("Document Type", PurchaseHeader."Document Type");
                Rec.Validate("Document No.", PurchaseHeader."No.");
            end;
        end;
    end;

    trigger OnAfterGetRecord()
    var
        PurchaseHeader: Record "Purchase Header";
        Item: Record Item;
        GLAccount: Record "G/L Account";
        UOM: Record "Unit of Measure";
        ItemVariant: Record "Item Variant";
        Location: Record Location;
    begin
        // Populate HeaderId
        if PurchaseHeader.Get(Rec."Document Type", Rec."Document No.") then
            HeaderId := PurchaseHeader.SystemId;
        
        // Populate Helper GUIDs for reading
        if Rec.Type = Rec.Type::Item then begin
            if Item.Get(Rec."No.") then ItemId := Item.SystemId;
        end else begin
            Clear(ItemId);
        end;

        if Rec.Type = Rec.Type::"G/L Account" then begin
            if GLAccount.Get(Rec."No.") then AccountId := GLAccount.SystemId;
        end else begin
            Clear(AccountId);
        end;

        if UOM.Get(Rec."Unit of Measure Code") then UOMId := UOM.SystemId else Clear(UOMId);
        // Note: Variant lookup requires Item No filter, simplified here:
        if (Rec."Variant Code" <> '') and (Rec.Type = Rec.Type::Item) then begin
           if ItemVariant.Get(Rec."No.", Rec."Variant Code") then VariantId := ItemVariant.SystemId;
        end else Clear(VariantId);

        if Location.Get(Rec."Location Code") then LocationId := Location.SystemId else Clear(LocationId);
    end;
}