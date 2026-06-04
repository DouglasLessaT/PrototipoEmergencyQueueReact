package models

import (
	"time"
	"github.com/google/uuid"
)

type QueuePatient struct {
	ID         				uuid.UUID `json:"id" gorm:"type:uuid;primary_key`
	NameQueue   			string `json:"nameQueue" gorm:"not null"`
	Discription 			string `json:"description" gorm:"not null"`
	CurenteQueueSize 		int       `json:"curenteQueueSize" gorm:"not null"`
	AverageWaitTime   		double `json:"averageWaitTime" gorm:"not null"`
	LastUpdated       		time.Time  `json:"lastUpdated" gorm:"not null;default:CURRENT_TIMESTAMP"`
	Patinents 				[]Patients `json:"patinent" gorm:"foreignKey:QueueID;references:ID"`
}