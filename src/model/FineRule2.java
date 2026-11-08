package model;

import java.io.Serializable;
import java.math.BigDecimal;

public class FineRule2 implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String violationType;
    private BigDecimal fixedAmount = BigDecimal.ZERO;
    private int percentageRate;

    public FineRule2() {}

    public FineRule2(int id, String violationType, BigDecimal fixedAmount, int percentageRate) {
        this.id = id;
        this.violationType = violationType;
        this.fixedAmount = fixedAmount;
        this.percentageRate = percentageRate;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getViolationType() { return violationType; }
    public void setViolationType(String violationType) { this.violationType = violationType; }

    public BigDecimal getFixedAmount() { return fixedAmount; }
    public void setFixedAmount(BigDecimal fixedAmount) { this.fixedAmount = fixedAmount; }

    public int getPercentageRate() { return percentageRate; }
    public void setPercentageRate(int percentageRate) { this.percentageRate = percentageRate; }
}
