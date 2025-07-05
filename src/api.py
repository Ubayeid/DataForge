from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Dict, Any
import logging
from datetime import datetime

from .pipeline import Pipeline
from .models import (
    PipelineRequest,
    PipelineResponse,
    DataSourceConfig,
    MetricsResponse
)

app = FastAPI(
    title="DataForge API",
    description="Enterprise Data Engineering Platform API",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "name": "DataForge API",
        "version": "1.0.0",
        "status": "operational"
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": "1.0.0"
    }

@app.post("/api/v1/pipelines", response_model=PipelineResponse)
async def create_pipeline(request: PipelineRequest):
    """Create and execute a data pipeline"""
    try:
        # Initialize pipeline
        pipeline = Pipeline(request.name)

        # Add source
        pipeline.read_from(
            request.source.type,
            options=request.source.options
        )

        # Add transformations
        for transform in request.transformations:
            pipeline.transform(
                transform.type,
                options=transform.options
            )

        # Add validations
        if request.validations:
            pipeline.validate(request.validations)

        # Add sink
        pipeline.write_to(
            request.target.type,
            options=request.target.options
        )

        # Execute pipeline
        result = pipeline.run(
            batch_mode=request.batch_mode,
            checkpoint_location=request.checkpoint_location
        )

        return PipelineResponse(
            pipeline_id=result["pipeline_id"],
            status="success",
            metrics=result.get("metrics"),
            timestamp=datetime.utcnow().isoformat()
        )

    except Exception as e:
        logger.error(f"Pipeline execution failed: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Pipeline execution failed: {str(e)}"
        )

@app.get("/api/v1/pipelines/{pipeline_id}/status")
async def get_pipeline_status(pipeline_id: str):
    """Get pipeline execution status"""
    try:
        # In a real implementation, fetch from database
        return {
            "pipeline_id": pipeline_id,
            "status": "running",
            "progress": 75,
            "start_time": "2024-03-04T10:00:00Z",
            "current_stage": "transformation"
        }
    except Exception as e:
        raise HTTPException(
            status_code=404,
            detail=f"Pipeline not found: {pipeline_id}"
        )

@app.get("/api/v1/metrics", response_model=MetricsResponse)
async def get_metrics():
    """Get system metrics"""
    return {
        "pipelines_executed": 1000,
        "success_rate": 99.9,
        "avg_processing_time": 120,
        "total_data_processed": "1.5TB",
        "active_pipelines": 5,
        "timestamp": datetime.utcnow().isoformat()
    }

@app.get("/api/v1/sources")
async def list_sources():
    """List available data sources"""
    return {
        "sources": [
            {
                "name": "kafka",
                "description": "Apache Kafka streaming source",
                "config_schema": {
                    "bootstrap_servers": "string",
                    "topic": "string",
                    "group_id": "string"
                }
            },
            {
                "name": "postgres",
                "description": "PostgreSQL database",
                "config_schema": {
                    "host": "string",
                    "port": "integer",
                    "database": "string",
                    "table": "string"
                }
            }
        ]
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)