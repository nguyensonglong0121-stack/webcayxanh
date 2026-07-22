package com.caycanhweb.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class StockTransaction {
    private long          transactionId;
    private int           productId;
    private String        productName;   // join từ products
    private String        type;          // import | export | adjust
    private int            quantity;
    private int           stockAfter;
    private String         note;
    private Integer        createdBy;
    private String          createdByName; // join từ users
    private LocalDateTime  createdAt;

    public StockTransaction() {}

    public long          getTransactionId()  { return transactionId; }
    public void          setTransactionId(long transactionId) { this.transactionId = transactionId; }
    public int           getProductId()      { return productId; }
    public void          setProductId(int productId) { this.productId = productId; }
    public String        getProductName()    { return productName; }
    public void          setProductName(String productName) { this.productName = productName; }
    public String        getType()           { return type; }
    public void          setType(String type) { this.type = type; }
    public int           getQuantity()       { return quantity; }
    public void          setQuantity(int quantity) { this.quantity = quantity; }
    public int           getStockAfter()     { return stockAfter; }
    public void          setStockAfter(int stockAfter) { this.stockAfter = stockAfter; }
    public String        getNote()           { return note; }
    public void          setNote(String note) { this.note = note; }
    public Integer       getCreatedBy()      { return createdBy; }
    public void          setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }
    public String        getCreatedByName()  { return createdByName; }
    public void          setCreatedByName(String createdByName) { this.createdByName = createdByName; }
    public LocalDateTime getCreatedAt()      { return createdAt; }
    public void          setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    /** Thời gian định dạng dd/MM/yyyy HH:mm để hiển thị */
    public String getCreatedAtFormatted() {
        return createdAt != null
                ? createdAt.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))
                : "";
    }

    /** Nhãn hiển thị tiếng Việt cho loại giao dịch */
    public String getTypeLabel() {
        return switch (type) {
            case "import" -> "Nhập kho";
            case "export" -> "Xuất kho";
            case "adjust" -> "Điều chỉnh";
            default       -> type;
        };
    }
}
